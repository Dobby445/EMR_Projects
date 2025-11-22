<%@ include file="header.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>비드CARE 메인</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
  <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
</head>
<body>
  <div class="d-flex">
    <!-- 사이드바 -->
    <div class="sidebar">
      <button class="btn btn-secondary">전체 대기 목록</button>
      <button class="btn btn-outline-secondary">내분비내과</button>
      <button class="btn btn-outline-secondary">순환기내과</button>
      <button class="btn btn-outline-secondary">신경과</button>
      <button class="btn btn-outline-secondary">혈액종양내과</button>
      <button class="btn btn-outline-secondary">호흡기내과</button>
      <button class="btn btn-outline-secondary">대장항문외과</button>
      <button class="btn btn-outline-secondary">신경외과</button>
      <button class="btn btn-outline-secondary">정형외과</button>
      <button class="btn btn-outline-secondary">소화기내과</button>
      <button class="btn btn-outline-secondary">피부과</button>
      <button class="btn btn-outline-secondary">비뇨기과</button>
      <button class="btn btn-outline-secondary">안과</button>
      <button class="btn btn-outline-secondary">이비인후과</button>
      <button class="btn btn-outline-secondary">정신과</button>
    </div>

    <!-- 메인 콘텐츠 -->
    <%@ page import="java.util.*, com.emrDAO.WaitingDAO, com.emrBean.WaitingBean" %>
    <%
    	WaitingDAO dao = WaitingDAO.getInstance();
    	List<WaitingBean> waitingList = dao.getWaitingList();
    	int waitingCount = (waitingList != null) ? waitingList.size() : 0;
	%>
	<%@ page import="java.util.*, com.emrDAO.ReceiptDAO, com.emrBean.ReceiptBean" %>
	<%
    	ReceiptDAO receiptDao = ReceiptDAO.getInstance();
    	List<ReceiptBean> unprocessedList = receiptDao.getUnprocessedReceipts();
	%>
    <div class="content-area">
      <!-- 그래프 / 요약 -->
      <div class="row mb-3">
        <div class="col-md-8">
          <div class="bg-white border rounded p-3" style="height:180px;">[그래프 영역]</div>
        </div>
        <div class="col-md-4">
          <div class="stat-card">총 진료 대기 인원: <strong><%= (waitingList == null ? 0 : waitingList.size()) %>명</strong></div>
          <div class="stat-card">수납 요청 처리: <strong><%= (unprocessedList == null ? 0 : unprocessedList.size()) %>건</strong></div>
        </div>
      </div>

      <!-- 리스트 2개 -->
  <div class="row">
  <!-- 왼쪽 -->
  <div class="col-md-6">
    <div class="panel-box">
      <h3>대기 환자 목록</h3>
      <ul class="waiting-list">
        <% if (waitingList == null || waitingList.isEmpty()) { %>
          <li class="text-center text-muted">현재 대기 중인 환자가 없습니다.</li>
        <% } else { %>
          <% for (WaitingBean w : waitingList) { %>
            <li>
              <div class="waiting-name"><%= w.getPatientName() %></div>
              <div class="waiting-info">
                <%= w.getGender() %> | <%= w.getBirth() %> <br>
                상태: <%= w.getState() %>
              </div>
            </li>
          <% } %>
        <% } %>
      </ul>
    </div>
  </div>

  <!-- 오른쪽 -->
  <div class="col-md-6">
    <div class="panel-box">
      <h3>수납 요청 미처리 목록 (<%= (unprocessedList == null ? 0 : unprocessedList.size()) %>건)</h3>
      <% if (unprocessedList == null || unprocessedList.isEmpty()) { %>
        <p class="text-center text-muted m-0">미처리된 수납 요청이 없습니다.</p>
      <% } else { %>
        <table class="receipt-table">
          <thead>
            <tr><th>환자명</th><th>카드번호</th></tr>
          </thead>
          <tbody>
            <% for (ReceiptBean r : unprocessedList) { %>
              <tr>
                <td><%= r.getPatientName() %></td>
                <td><%= (r.getCardNumber() == null ? "-" : r.getCardNumber()) %></td>
              </tr>
            <% } %>
          </tbody>
        </table>
      <% } %>
    </div>
  </div>
</div>
  
      
  </div>
</body>
</html>
