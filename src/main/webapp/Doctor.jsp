<%@ include file="header.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>Doctor - 비드CARE</title>
  <link rel="stylesheet" href="CSS/Doctor.css">
  <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
</head>
<body>
  <div class="doctor-container">
    <!-- 왼쪽: 대기 환자 목록 -->
    <div class="waiting-section">
      <h3>대기 환자</h3>
      <div id="waitingList"></div>
    </div>

    <!-- 중앙: 진료 기록 -->
    <div class="history-section">
      <h3>진료 기록</h3>
      <div id="historyList" class="empty-state">진료 기록을 선택하세요.</div>
    </div>

    <!-- 오른쪽: 진료 기록 작성 -->
    <div class="form-section">
      <h3>진료 기록 작성</h3>
      <form id="recordForm">
        <label>진료 메모</label>
        <textarea name="memo" class="form-control"></textarea>

        <label>증상</label>
        <textarea name="symptom_detail" class="form-control"></textarea>

        <label>혈압/체온</label>
        <div class="form-inline">
          <input type="text" name="bp_systolic" placeholder="수축" />
          <input type="text" name="bp_diastolic" placeholder="이완" />
          <input type="text" name="temp" placeholder="체온" />
        </div>
        <button type="button" id="saveBtn">저장</button>
      </form>
    </div>
  </div>
  <script src="js/Doctor.js"></script>
</body>
</html>
