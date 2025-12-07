<%@ include file="header.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, com.emrDAO.WaitingDAO, com.emrBean.WaitingBean" %>

<%
    // 대기 환자 목록 가져오기
    WaitingDAO waitDao = WaitingDAO.getInstance();
    List<WaitingBean> waitingList = waitDao.getWaitingList();
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>접수/수납 - Nurse</title>
    <style>
        body { background-color: #f5f6fa; }
        
        .sidebar {
            width: 280px;
            background: #fff;
            border-right: 1px solid #ddd;
            height: calc(100vh - 56px);
            overflow-y: auto;
            padding: 0;
        }
        
        .sidebar-header {
            padding: 15px;
            background-color: #343a40;
            color: white;
            font-weight: bold;
            text-align: center;
        }

        .waiting-item {
            display: block;
            padding: 15px;
            border-bottom: 1px solid #eee;
            color: #333;
            text-decoration: none;
            cursor: pointer; /* 클릭 가능 표시 */
            transition: background 0.2s;
        }
        .waiting-item:hover { background-color: #f1f3f5; }
        
        .content-area {
            flex: 1;
            padding: 30px;
            overflow-y: auto;
            height: calc(100vh - 56px);
        }

        .nav-tabs .nav-link { color: #495057; font-weight: bold; }
        .nav-tabs .nav-link.active { color: #0d6efd !important; border-bottom: 3px solid #0d6efd; }
        
        .form-panel {
            background: white;
            padding: 30px;
            border-radius: 0 0 10px 10px;
            border: 1px solid #dee2e6;
            border-top: none;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
        }
    </style>
</head>
<body>

<div class="d-flex">
    
    <div class="sidebar">
        <div class="sidebar-header">
              실시간 대기 현황
        </div>
        <% if (waitingList == null || waitingList.isEmpty()) { %>
            <div class="p-3 text-center text-muted">대기 환자가 없습니다.</div>
        <% } else { %>
            <% for (WaitingBean w : waitingList) { %>
            <div class="waiting-item" onclick="loadPatientInfo('<%= w.getPatientId() %>', '<%= w.getId() %>')">
                <div class="d-flex justify-content-between align-items-center">
                    <strong><%= w.getPatientName() %></strong>
                    <span class="badge bg-<%= w.getState().equals("진료중") ? "success" : "secondary" %>"><%= w.getState() %></span>
                </div>
                <div class="small text-muted mt-1">
                    <%= w.getBirth() %> | <%= w.getGender() %>
                </div>
            </div>
            <% } %>
        <% } %>
    </div>

    <div class="content-area">
        <h3 class="mb-4 fw-bold"> 환자 관린 </h3>

        <ul class="nav nav-tabs" id="nurseTab" role="tablist">
            <li class="nav-item" role="presentation">
                <button class="nav-link active" id="register-tab" data-bs-toggle="tab" data-bs-target="#register" type="button">👤 신규 환자 등록</button>
            </li>
            <li class="nav-item" role="presentation">
                <button class="nav-link" id="queue-tab" data-bs-toggle="tab" data-bs-target="#queue" type="button">🩺 진료 대기 접수</button>
            </li>
            <li class="nav-item" role="presentation">
                <button class="nav-link text-danger" id="manage-tab" data-bs-toggle="tab" data-bs-target="#manage" type="button">⚙️ 환자 관리 (수정/취소)</button>
            </li>
        </ul>

        <div class="tab-content">
            
            <div class="tab-pane fade show active" id="register">
                <div class="form-panel">
                    <h5 class="mb-3 text-primary">신규 환자 정보 입력</h5>
                    <form id="formNewPatient">
                        <input type="hidden" name="mode" value="register_patient">
                        <div class="mb-3"><label>환자명</label><input type="text" class="form-control" name="name" required></div>
                        <div class="row mb-3">
                            <div class="col-md-6"><label>주민번호</label><div class="d-flex"><input type="text" class="form-control" name="jumin1" maxlength="6"><span class="mx-2">-</span><input type="password" class="form-control" name="jumin2" maxlength="7"></div></div>
                            <div class="col-md-6"><label>연락처</label><input type="text" class="form-control" name="phone" placeholder="010-0000-0000"></div>
                        </div>
                        <div class="text-end"><button type="button" class="btn btn-primary" onclick="submitForm('formNewPatient')">저장</button></div>
                    </form>
                </div>
            </div>

            <div class="tab-pane fade" id="queue">
                <div class="form-panel">
                    <h5 class="mb-3 text-success">기존 환자 대기열 등록</h5>
                    <form id="formAddQueue">
                        <input type="hidden" name="mode" value="add_queue">
                        <div class="mb-3"><label>환자 ID</label><input type="text" class="form-control" name="patient_id" placeholder="ID 입력"></div>
                        <div class="mb-3"><label>증상</label><input type="text" class="form-control" name="symptom"></div>
                        <div class="text-end"><button type="button" class="btn btn-success" onclick="submitForm('formAddQueue')">접수</button></div>
                    </form>
                </div>
            </div>

            <div class="tab-pane fade" id="manage">
                <div class="form-panel border-danger" style="border-top:1px solid #dc3545;">
                    <h5 class="mb-3 text-danger">환자 정보 수정 및 대기 취소</h5>
                    <div id="manage-msg" class="alert alert-secondary text-center">왼쪽 목록에서 환자를 선택하세요.</div>
                    
                    <form id="formManage" style="display:none;">
                        <input type="hidden" name="mode" value="update_patient">
                        <input type="hidden" name="patient_id" id="m_id">
                        <input type="hidden" name="waiting_id" id="m_waiting_id">
                        
                        <div class="row mb-3">
                            <div class="col-md-6"><label>환자명</label><input type="text" class="form-control" name="name" id="m_name"></div>
                            <div class="col-md-6"><label>연락처</label><input type="text" class="form-control" name="phone" id="m_phone"></div>
                        </div>
                        <div class="mb-3">
                            <label>생년월일 / 성별 (수정불가)</label>
                            <input type="text" class="form-control" id="m_info" readonly disabled>
                        </div>

                        <hr>
                        <div class="d-flex justify-content-between">
                            <button type="button" class="btn btn-danger" onclick="cancelWaiting()">🚨 대기 취소 (목록 제거)</button>
                            <button type="button" class="btn btn-primary" onclick="submitForm('formManage')">정보 수정 저장</button>
                        </div>
                    </form>
                </div>
            </div>

        </div> 
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // 1. 왼쪽 목록 클릭 시 실행되는 함수
    function loadPatientInfo(patientId, waitingId) {
        // 관리 탭 활성화
        var triggerEl = document.querySelector('#nurseTab button[data-bs-target="#manage"]');
        bootstrap.Tab.getOrCreateInstance(triggerEl).show();

        // AJAX로 환자 상세 정보 가져오기
        $.ajax({
            type: "POST",
            url: "registerProcess.jsp",
            data: { mode: "get_info", patient_id: patientId },
            dataType: "json",
            success: function(res) {
                if(res.success) {
                    $("#manage-msg").hide();
                    $("#formManage").show();
                    
                    // 폼 채우기
                    $("#m_id").val(res.data.id);
                    $("#m_waiting_id").val(waitingId); // 대기 취소용 ID
                    $("#m_name").val(res.data.name);
                    $("#m_phone").val(res.data.phone);
                    $("#m_info").val(res.data.birth + " / " + res.data.gender);
                } else {
                    alert("환자 정보를 불러오지 못했습니다.");
                }
            }
        });
    }

    // 2. 대기 취소 (목록 제거)
    function cancelWaiting() {
        if(!confirm("정말 대기 목록에서 삭제하시겠습니까?")) return;
        
        let waitingId = $("#m_waiting_id").val();
        $.ajax({
            type: "POST",
            url: "registerProcess.jsp",
            data: { mode: "cancel_waiting", waiting_id: waitingId },
            dataType: "json",
            success: function(res) {
                if(res.success) {
                    alert("대기가 취소되었습니다.");
                    location.reload();
                } else {
                    alert("취소 실패: " + res.message);
                }
            }
        });
    }

    // 3. 폼 제출 (등록/수정)
    function submitForm(formId) {
        $.ajax({
            type: "POST",
            url: "registerProcess.jsp",
            data: $("#" + formId).serialize(),
            dataType: "json",
            success: function(res) {
                if(res.success) {
                    alert(res.message);
                    if (formId === 'formNewPatient') {
                        prompt("환자 ID가 생성되었습니다.", res.generatedId);
                        $("#" + formId)[0].reset();
                    } else {
                        location.reload(); 
                    }
                } else {
                    alert("오류: " + res.message);
                }
            },
            error: function() { alert("서버 통신 오류"); }
        });
    }
</script>

</body>
</html>