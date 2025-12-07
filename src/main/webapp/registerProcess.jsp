<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.emrDAO.PatientDAO, com.emrDAO.WaitingDAO, com.emrBean.PatientBean" %>
<%@ page import="java.util.UUID" %>

<%
    request.setCharacterEncoding("UTF-8");
    String mode = request.getParameter("mode");
    
    boolean success = false;
    String message = "";
    String generatedId = "";
    String jsonData = "null"; // 조회용 데이터

    PatientDAO pDao = PatientDAO.getInstance();
    WaitingDAO wDao = WaitingDAO.getInstance();

    try {
        if ("register_patient".equals(mode)) {
            // [신규 등록]
            String name = request.getParameter("name");
            String jumin1 = request.getParameter("jumin1");
            String jumin2 = request.getParameter("jumin2");
            String phone = request.getParameter("phone");
            
            String gender = (jumin2.charAt(0) == '1' || jumin2.charAt(0) == '3') ? "남성" : "여성";
            String yearPrefix = (jumin2.charAt(0) == '1' || jumin2.charAt(0) == '2') ? "19" : "20";
            String birth = yearPrefix + jumin1.substring(0, 2) + "-" + jumin1.substring(2, 4) + "-" + jumin1.substring(4, 6);
            
            generatedId = UUID.randomUUID().toString().substring(0, 8);
            success = pDao.insertPatient(generatedId, name, gender, birth, phone);
            message = success ? "환자 등록 완료" : "환자 등록 실패";

        } else if ("add_queue".equals(mode)) {
            // [대기열 추가]
            String patientId = request.getParameter("patient_id");
            success = wDao.addWaiting(UUID.randomUUID().toString().substring(0, 8), "GEN", patientId);
            message = success ? "접수 완료" : "접수 실패 (ID 확인)";

        } else if ("get_info".equals(mode)) {
            // [정보 조회] - 수정 탭에 채울 데이터
            String pid = request.getParameter("patient_id");
            PatientBean p = pDao.getPatientById(pid);
            if (p != null) {
                success = true;
                jsonData = String.format("{\"id\":\"%s\", \"name\":\"%s\", \"phone\":\"%s\", \"birth\":\"%s\", \"gender\":\"%s\"}",
                        p.getId(), p.getName(), p.getPhone(), p.getBirth(), p.getGender());
            }

        } else if ("update_patient".equals(mode)) {
            // [정보 수정]
            String pid = request.getParameter("patient_id");
            String name = request.getParameter("name");
            String phone = request.getParameter("phone");
            success = pDao.updatePatient(pid, name, phone);
            message = success ? "정보가 수정되었습니다." : "수정 실패";

        } else if ("cancel_waiting".equals(mode)) {
            // [대기 취소]
            String wid = request.getParameter("waiting_id");
            success = wDao.deleteWaiting(wid);
            message = success ? "대기 취소 완료" : "취소 실패";
        }

    } catch (Exception e) {
        message = "에러: " + e.getMessage();
        e.printStackTrace();
    }

    out.print("{");
    out.print("\"success\": " + success + ",");
    out.print("\"message\": \"" + message + "\",");
    out.print("\"generatedId\": \"" + generatedId + "\",");
    out.print("\"data\": " + jsonData);
    out.print("}");
%>