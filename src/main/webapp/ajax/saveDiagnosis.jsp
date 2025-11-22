<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.emrDAO.HistoryDAO, com.emrBean.HistoryBean, java.util.UUID" %>

<%
    request.setCharacterEncoding("UTF-8");
    response.setContentType("application/json; charset=UTF-8");

    // 폼 데이터 수집
    String memo = request.getParameter("memo");
    String symptomDetail = request.getParameter("symptom_detail");
    String bpSystolic = request.getParameter("bp_systolic");
    String bpDiastolic = request.getParameter("bp_diastolic");
    String temp = request.getParameter("temp");
    String patientId = request.getParameter("patient_id");
    String employeeId = (String) session.getAttribute("Id"); // 로그인한 의사
    String deptId = "D001"; // 예시: 실제로는 세션 또는 선택값에서 받아야 함

    boolean result = false;
    String message = "";

    try {
        if (patientId != null && !patientId.trim().isEmpty()) {
            HistoryBean bean = new HistoryBean();
            bean.setId(UUID.randomUUID().toString().substring(0, 8));
            bean.setPatientId(patientId);
            bean.setEmployeeId(employeeId);
            bean.setDeptId(deptId);
            bean.setMemo(memo);
            bean.setSymptomDetail(symptomDetail);
            bean.setBpSystolic(Integer.parseInt(bpSystolic));
            bean.setBpDiastolic(Integer.parseInt(bpDiastolic));
            bean.setTemp(Float.parseFloat(temp));

            HistoryDAO dao = HistoryDAO.getInstance();
            result = dao.insertHistory(bean);

            if (result) {
                message = "진료 기록이 성공적으로 저장되었습니다.";
            } else {
                message = "진료 기록 저장에 실패했습니다.";
            }
        } else {
            message = "환자 정보가 없습니다.";
        }
    } catch (Exception e) {
        message = "예외 발생: " + e.getMessage();
        e.printStackTrace();
    }

    // JSON 응답
    out.print("{");
    out.print("\"success\": " + result + ",");
    out.print("\"message\": \"" + message + "\"");
    out.print("}");
%>
