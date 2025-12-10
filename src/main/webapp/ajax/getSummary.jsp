<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*, java.net.*, java.util.*" %>
<%@ page import="com.emrDAO.HistoryDAO, com.emrBean.HistoryBean" %>


<%
    // 1. 요청 인코딩 설정
    request.setCharacterEncoding("UTF-8");

    // 2. 클라이언트(Doctor.jsp)에서 보낸 파라미터 받기
    String height = request.getParameter("height");
    String weight = request.getParameter("weight");
    String bpSys = request.getParameter("bp_systolic");
    String bpDia = request.getParameter("bp_diastolic");
    String temp = request.getParameter("temp");
    String symptom = request.getParameter("symptom_detail");
    String memo = request.getParameter("memo");

    // null 값 처리 (빈 문자열이나 null이면 "null" 텍스트가 아닌 실제 JSON null로 처리하기 위함이나, 
    // 여기서는 문자열 "null"이나 빈값으로 보내는 게 Python에서 처리하기 편할 수 있습니다. 
    // 일단 안전하게 빈 문자열("")로 치환합니다.)
    if(height == null) height = "";
    if(weight == null) weight = "";
    if(bpSys == null) bpSys = "";
    if(bpDia == null) bpDia = "";
    if(temp == null) temp = "";
    if(symptom == null) symptom = "";
    if(memo == null) memo = "";

    // 3. Python 서버로 보낼 JSON 문자열 직접 생성
    // (라이브러리 없이 문자열 결합으로 생성. 줄바꿈 문자 등 이스케이프 처리가 필요할 수 있으나 기본 기능에 집중합니다.)
    // Python 쪽에서 받을 키(Key) 이름과 일치해야 합니다.
    StringBuilder jsonBuilder = new StringBuilder();
    jsonBuilder.append("{");
    jsonBuilder.append("\"height\": \"" + height + "\",");
    jsonBuilder.append("\"weight\": \"" + weight + "\",");
    jsonBuilder.append("\"bp_systolic\": \"" + bpSys + "\",");
    jsonBuilder.append("\"bp_diastolic\": \"" + bpDia + "\",");
    jsonBuilder.append("\"temp\": \"" + temp + "\",");
    jsonBuilder.append("\"symptom_detail\": \"" + symptom.replace("\"", "\\\"").replace("\n", "\\n") + "\","); 
    jsonBuilder.append("\"memo\": \"" + memo.replace("\"", "\\\"").replace("\n", "\\n") + "\"");
    jsonBuilder.append("}");

    String jsonInputString = jsonBuilder.toString();
    
    // 4. Python AI 서버로 요청 전송
    // [주의] Python 서버 주소와 포트를 정확히 입력하세요.
    String targetUrl = "http://localhost:5000/summarize"; 
    
    HttpURLConnection conn = null;
    BufferedReader br = null;
    StringBuilder responseSb = new StringBuilder();

    try {
        URL url = new URL(targetUrl);
        conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
        conn.setRequestProperty("Accept", "application/json");
        conn.setDoOutput(true);

        // 데이터 전송
        try(OutputStream os = conn.getOutputStream()) {
            byte[] input = jsonInputString.getBytes("UTF-8");
            os.write(input, 0, input.length);
        }

        // 응답 수신
        int status = conn.getResponseCode();
        InputStream is = (status >= 200 && status < 300) ? conn.getInputStream() : conn.getErrorStream();
        
        br = new BufferedReader(new InputStreamReader(is, "UTF-8"));
        String line;
        while ((line = br.readLine()) != null) {
            responseSb.append(line);
        }

    } catch (Exception e) {
        // 에러 발생 시 JSON 형태의 에러 메시지 생성
        responseSb.setLength(0); // 비우기
        responseSb.append("{\"success\": false, \"message\": \"Java Server Error: " + e.getMessage() + "\"}");
    } finally {
        if(br != null) try { br.close(); } catch(Exception e){}
        if(conn != null) conn.disconnect();
    }

    // 5. 결과 출력 (브라우저로 전달)
    out.clear(); // JSP 공백 제거용
    out.print(responseSb.toString());
%>