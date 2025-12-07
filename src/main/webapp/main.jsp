<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="com.emrDAO.WaitingDAO, com.emrBean.WaitingBean" %>
<%@ page import="com.emrDAO.HistoryDAO, com.emrBean.HistoryBean" %>
<%@ page import="com.emrDAO.PatientDAO, com.emrBean.PatientBean" %>

<%@ include file="header.jsp" %>

<%
    // --- [서버 로직] 데이터 로딩 (사이드바 데이터 로딩 부분 삭제됨 - sidebar.jsp가 알아서 함) ---

    // 1. 선택된 환자 ID 확인
    String selectedId = request.getParameter("selectId");
    
    WaitingBean currentPatient = null;
    List<HistoryBean> patientHistoryList = null;
    
    // 2. 환자 정보 찾기 (대기 목록 -> 없으면 전체 DB)
    WaitingDAO waitDao = WaitingDAO.getInstance();
    List<WaitingBean> waitingList = waitDao.getWaitingList(); // 메인 로직용으로 필요함

    if (waitingList != null && selectedId != null) {
        for (WaitingBean w : waitingList) {
            if (w.getPatientId().equals(selectedId)) {
                currentPatient = w;
                break;
            }
        }
    }

    if (currentPatient == null && selectedId != null) {
        PatientDAO pDao = PatientDAO.getInstance();
        PatientBean pBean = pDao.getPatientById(selectedId);
        
        if (pBean != null) {
            currentPatient = new WaitingBean();
            currentPatient.setPatientId(pBean.getId());
            currentPatient.setPatientName(pBean.getName());
            currentPatient.setGender(pBean.getGender());
            currentPatient.setBirth(pBean.getBirth());
            currentPatient.setPhone(pBean.getPhone());
            currentPatient.setState("비대기");
            currentPatient.setEntryDate(null);
        }
    }

    // 기본값: 리스트 첫 번째
    if (currentPatient == null && waitingList != null && !waitingList.isEmpty()) {
        currentPatient = waitingList.get(0);
        selectedId = currentPatient.getPatientId();
    }

    // 3. 진료 기록 가져오기
    if (currentPatient != null) {
        HistoryDAO historyDao = HistoryDAO.getInstance();
        patientHistoryList = historyDao.getHistoryByPatient(currentPatient.getPatientId());
    }
%>

<style>
    /* 전체 배경 */
    body { background-color: #f5f6fa; }

    /* 콘텐츠 영역 */
    .content-area {
        flex: 1;
        padding: 20px;
        overflow-y: auto;
        height: calc(100vh - 56px);
    }

    /* 패널 박스 */
    .panel-box {
        background: #fff;
        border: 1px solid #eee;
        border-radius: 10px;
        padding: 25px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.05);
        height: 100%;
    }

    .section-title {
        font-size: 1.2rem;
        font-weight: bold;
        color: #2c3e50;
        border-bottom: 2px solid #0d6efd;
        padding-bottom: 10px;
        margin-bottom: 20px;
    }

    /* 테이블 */
    .info-table th { width: 100px; color: #666; font-weight: normal; }
    .info-table td { font-weight: bold; color: #333; }

    /* 진료기록 카드 */
    .prescription-card {
        border: 1px solid #dfe6e9;
        background-color: #fdfdfd;
        padding: 15px;
        border-radius: 8px;
        margin-bottom: 10px;
    }
    
    /* 이전 기록 리스트 스크롤 */
    .history-list {
        max-height: 200px; 
        overflow-y: auto;
    }
</style>

<div class="d-flex">
    
    <jsp:include page="sidebar.jsp" />

    <div class="content-area">
        
        <div class="row mb-4">
            <div class="col-12">
                <div class="alert alert-light border d-flex justify-content-between align-items-center">
                    <span><strong>Today:</strong> <%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %></span>
                    <span>현재 조회 중: <strong><%= currentPatient != null ? currentPatient.getPatientName() : "없음" %></strong></span>
                </div>
            </div>
        </div>

        <div class="row" style="height: 70vh;">
            
            <div class="col-md-5">
                <div class="panel-box">
                    <h3 class="section-title">👤 환자 상세 정보</h3>
                    
                    <% if (currentPatient != null) { %>
                        <div class="text-center mb-4">
                            <img src="images/profile_placeholder.png" onerror="this.src='https://via.placeholder.com/100?text=User'" class="rounded-circle mb-2" width="100" height="100">
                            <h4><%= currentPatient.getPatientName() %></h4>
                            <span class="text-muted"><%= currentPatient.getPatientId() %></span>
                        </div>

                        <table class="table table-borderless info-table">
                            <tr>
                                <th>생년월일</th>
                                <td><%= currentPatient.getBirth() %></td>
                            </tr>
                            <tr>
                                <th>성별</th>
                                <td><%= currentPatient.getGender() %></td>
                            </tr>
                            <tr>
                                <th>연락처</th>
                                <td><%= currentPatient.getPhone() %></td>
                            </tr>
                            <tr>
                                <th>현재 상태</th>
                                <td>
                                    <span class="badge bg-<%= "비대기".equals(currentPatient.getState()) ? "secondary" : "primary" %>">
                                        <%= currentPatient.getState() %>
                                    </span>
                                </td>
                            </tr>
                            <tr>
                                <th>접수 시간</th>
                                <td><%= currentPatient.getEntryDate() != null ? currentPatient.getEntryDate() : "-" %></td>
                            </tr>
                        </table>
                        
                        <div class="d-grid gap-2 mt-4">
                            <button class="btn btn-outline-primary" type="button" onclick="alert('기능 준비중입니다.')">상세 정보 수정</button>
                            <button class="btn btn-primary" type="button" onclick="location.href='Doctor.jsp'">진료실로 이동</button>
                        </div>

                    <% } else { %>
                        <div class="d-flex align-items-center justify-content-center h-100 text-muted">
                            왼쪽 목록에서 환자를 선택하거나<br>상단 검색창을 이용하세요.
                        </div>
                    <% } %>
                </div>
            </div>

            <div class="col-md-7">
                <div class="panel-box">
                    <h3 class="section-title">최근 처방 및 진료 기록</h3>
                    
                    <% if (currentPatient != null) { %>
                        
                        <% if (patientHistoryList != null && !patientHistoryList.isEmpty()) { 
                            HistoryBean latestHistory = patientHistoryList.get(0); 
                        %>
                            <div class="card border-primary mb-3">
                                <div class="card-header bg-primary text-white d-flex justify-content-between">
                                    <span>진료일: <%= latestHistory.getEntryDate() %></span>
                                    <span>담당의: <%= latestHistory.getEmployeeId() %></span>
                                </div>
                                <div class="card-body">
                                    <h5 class="card-title">진료 메모 (Diagnose)</h5>
                                    <p class="card-text p-3 bg-light rounded"><%= latestHistory.getMemo() %></p>
                                    
                                    <h5 class="card-title mt-3">증상 상세</h5>
                                    <p class="card-text"><%= latestHistory.getSymptomDetail() %></p>
                                    
                                    <hr>
                                    <div class="row text-center">
                                        <div class="col">
                                            <small class="text-muted">혈압</small><br>
                                            <strong><%= latestHistory.getBpSystolic() %> / <%= latestHistory.getBpDiastolic() %></strong>
                                        </div>
                                        <div class="col">
                                            <small class="text-muted">체온</small><br>
                                            <strong><%= latestHistory.getTemp() %>℃</strong>
                                        </div>
                                        <div class="col">
                                            <small class="text-muted">키/몸무게</small><br>
                                            <strong><%= latestHistory.getHeight() %>cm / <%= latestHistory.getWeight() %>kg</strong>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <% if (patientHistoryList.size() > 1) { %>
                                <h5 class="mt-4 mb-2 text-muted">이전 기록</h5>
                                <ul class="list-group history-list">
                                    <% for(int i=1; i<patientHistoryList.size(); i++) { 
                                        HistoryBean h = patientHistoryList.get(i);
                                    %>
                                    <li class="list-group-item d-flex justify-content-between align-items-center">
                                        <span><%= h.getEntryDate() %> - <%= h.getMemo().length() > 20 ? h.getMemo().substring(0, 20)+"..." : h.getMemo() %></span>
                                        <span class="badge bg-secondary rounded-pill">조회</span>
                                    </li>
                                    <% } %>
                                </ul>
                            <% } %>

                        <% } else { %>
                            <div class="alert alert-info text-center mt-5">
                                이전 진료/처방 기록이 없습니다. (신환)
                            </div>
                        <% } %>

                    <% } else { %>
                        <div class="d-flex align-items-center justify-content-center h-100 text-muted">
                            환자를 선택하면 진료 기록이 표시됩니다.
                        </div>
                    <% } %>
                </div>
            </div>

        </div> 
    </div> 
</div> 

<script>
    function onPatientClick(patientId, waitingId) {
        // 메인 페이지는 클릭 시 해당 환자 ID로 새로고침(이동)합니다.
        location.href = "main.jsp?selectId=" + patientId;
    }
</script>

</body>
</html>