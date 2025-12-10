<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="com.emrDAO.WaitingDAO, com.emrBean.WaitingBean" %>
<%@ page import="com.emrDAO.HistoryDAO, com.emrBean.HistoryBean" %>
<%@ page import="com.emrDAO.PatientDAO, com.emrBean.PatientBean" %>

<%@ include file="header.jsp" %>

<%
    // --- [서버 로직] ---
    request.setCharacterEncoding("UTF-8");

    WaitingDAO waitDao = WaitingDAO.getInstance();
    List<WaitingBean> waitingList = waitDao.getWaitingList();
    
    String selectedId = request.getParameter("selectId");
    WaitingBean currentPatient = null;
    
    // 환자 찾기
    if (waitingList != null && !waitingList.isEmpty()) {
        if (selectedId == null) {
            currentPatient = waitingList.get(0);
        } else {
            for (WaitingBean w : waitingList) {
                if (w.getPatientId().equals(selectedId)) {
                    currentPatient = w;
                    break;
                }
            }
            if (currentPatient == null) {
                PatientDAO pDao = PatientDAO.getInstance();
                PatientBean p = pDao.getPatientById(selectedId);
                if(p != null) {
                    currentPatient = new WaitingBean();
                    currentPatient.setPatientId(p.getId());
                    currentPatient.setPatientName(p.getName());
                    currentPatient.setGender(p.getGender());
                    currentPatient.setBirth(p.getBirth());
                    currentPatient.setState("조회중");
                }
            }
        }
    }
    
    // 진료 기록 조회
    List<HistoryBean> historyList = null;
    if (currentPatient != null) {
        HistoryDAO hDao = HistoryDAO.getInstance();
        historyList = hDao.getHistoryByPatient(currentPatient.getPatientId());
    }
%>

<style>
    /* [기본 레이아웃 - 사이드바 포함] */
    body { background-color: #f5f6fa; overflow: hidden; margin: 0 !important; padding: 0 !important; }
    
    /* 사이드바 스타일 (원복됨) */
    .sidebar {
        width: 280px;
        background: #fff;
        border-right: 1px solid #ddd;
        height: calc(100vh - 56px);
        overflow-y: auto;
        flex-shrink: 0;
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
        transition: 0.2s;
        cursor: pointer;
    }
    .waiting-item:hover { background-color: #f1f3f5; color: #000; }
    .waiting-item.active { background-color: #e7f5ff; border-left: 5px solid #0d6efd; }

    /* 콘텐츠 영역 */
    .content-area {
        flex: 1;
        padding: 20px;
        overflow-y: auto;
        height: calc(100vh - 56px);
    }
    .panel-box {
        background: #fff;
        border: 1px solid #ccc; /* 테두리 조금 더 진하게 */
        border-radius: 4px;     /* EMR 느낌나게 각지게 */
        padding: 0;             /* 패딩 제거 (내부에서 조절) */
        height: 100%;
        overflow-y: auto;
        display: flex;
        flex-direction: column;
    }

    /* [EMR 스타일 전용 CSS] */
    .emr-header {
        background-color: #e9ecef;
        border-bottom: 1px solid #ced4da;
        padding: 8px 15px;
        font-size: 0.9rem;
        font-weight: bold;
        color: #495057;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }
    
    .emr-section-label {
        font-size: 0.85rem;
        font-weight: bold;
        color: #666;
        margin-bottom: 5px;
        display: block;
        border-left: 3px solid #0d6efd;
        padding-left: 8px;
    }

    .emr-input {
        font-size: 0.9rem;
        border-radius: 2px;
    }
    
    .input-group-text {
        font-size: 0.8rem;
        background-color: #f8f9fa;
    }
    
    .history-card-item.active {
        color: #000000 !important; /* 글자색 검정 */
    }
    
    }
</style>

<div class="d-flex" style="width: 100vw;">
    
    <div class="sidebar">
        <div class="sidebar-header">
             대기 환자 목록 (<%= waitingList != null ? waitingList.size() : 0 %>명)
        </div>
        
        <% if (waitingList == null || waitingList.isEmpty()) { %>
            <div class="p-3 text-center text-muted">대기 환자가 없습니다.</div>
        <% } else { %>
            <% for (WaitingBean w : waitingList) { 
                String isActive = (currentPatient != null && w.getPatientId().equals(currentPatient.getPatientId())) ? "active" : "";
            %>
            <a href="Doctor.jsp?selectId=<%= w.getPatientId() %>" class="waiting-item <%= isActive %>">
                <div class="d-flex justify-content-between align-items-center">
                    <strong><%= w.getPatientName() %></strong>
                    <span class="badge bg-<%= "진료중".equals(w.getState()) ? "success" : "secondary" %>"><%= w.getState() %></span>
                </div>
                <div class="small text-muted mt-1">
                    <%= w.getBirth() %> | <%= w.getGender() %>
                </div>
            </a>
            <% } %>
        <% } %>
    </div>

    <div class="content-area p-3 w-100" style="background-color: #f5f6fa;">
        <div class="row h-100 g-3">
            
            <div class="col-md-4 h-100">
                <div class="panel-box">
                    <div class="emr-header">
                        <span> 과거 진료 기록</span>
                    </div>
                    
                    <div class="p-3" style="flex: 1; overflow-y: auto;">
                        <% if (historyList != null && !historyList.isEmpty()) { %>
                            <% for (HistoryBean h : historyList) { %>
                            <div class="card mb-2 border rounded-0 history-card-item" style="cursor: pointer; font-size: 0.9rem;"
                                 onclick="loadHistoryToForm(this)"
                                 data-id="<%= h.getId() %>"
                                 data-symptom="<%= h.getSymptomDetail() %>"
                                 data-memo="<%= h.getMemo() %>"
                                 data-bpsys="<%= h.getBpSystolic() %>"
                                 data-bpdia="<%= h.getBpDiastolic() %>"
                                 data-temp="<%= h.getTemp() %>"
                                 data-weight="<%= h.getWeight() %>"
                                 data-height="<%= h.getHeight() %>">
                                
                                <div class="card-header py-1 px-2 d-flex justify-content-between align-items-center bg-light">
                                    <strong><%= h.getEntryDate().toString().substring(0, 10) %></strong>
                                    <span class="badge bg-secondary" style="font-weight: normal;">Dr. <%= h.getEmployeeId() %></span>
                                </div>
                                <div class="card-body py-2 px-2">
                                    <div class="text-truncate mb-1"><span class="text-primary">S)</span> <%= h.getSymptomDetail() %></div>
                                    <div class="text-truncate"><span class="text-danger">P)</span> <%= h.getMemo() %></div>
                                </div>
                            </div>
                            <% } %>
                        <% } else { %>
                            <div class="text-center text-muted mt-5 small">기록 없음</div>
                        <% } %>
                    </div>
                </div>
            </div>

            <div class="col-md-8 h-100">
                <div class="panel-box">
                    
                    <div class="emr-header">
                        <span>
                            <span class="text-primary"> 진료 기록 작성</span> 
                            <% if(currentPatient != null) { %>
                                <span class="mx-2">|</span> 
                                <strong><%= currentPatient.getPatientName() %></strong> 
                                <span class="text-muted small">(<%= currentPatient.getGender() %> / <%= currentPatient.getBirth() %>)</span>
                            <% } %>
                        </span>
                        <% if(currentPatient != null) { %>
                            <button type="button" class="btn btn-sm btn-outline-secondary py-0" onclick="resetForm()" style="font-size: 0.8rem;">🔄 신규작성</button>
                        <% } %>
                    </div>

                    <form id="recordForm" style="flex: 1; display: flex; flex-direction: column; padding: 15px; overflow-y: auto;">
                        <input type="hidden" name="patient_id" value="<%= (currentPatient != null) ? currentPatient.getPatientId() : "" %>">
                        <input type="hidden" name="history_id" id="history_id">

                        <span class="emr-section-label">신체계측 / 바이탈 (Vitals)</span>
                        <div class="row g-2 mb-3 p-2 bg-light border rounded-1">
                            <div class="col-md-3">
                                <div class="input-group input-group-sm">
                                    <span class="input-group-text">키</span>
                                    <input type="text" name="height" id="height" class="form-control emr-input">
                                    <span class="input-group-text">cm</span>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="input-group input-group-sm">
                                    <span class="input-group-text">체중</span>
                                    <input type="text" name="weight" id="weight" class="form-control emr-input">
                                    <span class="input-group-text">kg</span>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="input-group input-group-sm">
                                    <span class="input-group-text">혈압</span>
                                    <input type="text" name="bp_systolic" id="bp_systolic" class="form-control emr-input text-center" placeholder="120">
                                    <span class="input-group-text px-1">/</span>
                                    <input type="text" name="bp_diastolic" id="bp_diastolic" class="form-control emr-input text-center" placeholder="80">
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="input-group input-group-sm">
                                    <span class="input-group-text">체온</span>
                                    <input type="text" name="temp" id="temp" class="form-control emr-input">
                                    <span class="input-group-text">℃</span>
                                </div>
                            </div>
                        </div>

                        <span class="emr-section-label mt-2">증상 및 호소 (Subjective)</span>
                        <div class="mb-3">
                            <textarea name="symptom_detail" id="symptom_detail" class="form-control emr-input" rows="4" placeholder="환자의 주 호소 증상을 입력하세요."></textarea>
                        </div>

                        <span class="emr-section-label">진료 소견 및 처방 (Assessment & Plan)</span>
                        <div class="mb-3" style="flex: 1;">
                            <textarea name="memo" id="memo" class="form-control emr-input h-100" rows="6" placeholder="진단명, 처방 내역, 의사 소견 등을 입력하세요."></textarea>
                        </div>
                        
                        <div class="mb-3" id="summaryContainer" style="display: none;">
	                        <span class="emr-section-label text-success" style="border-left-color: #198754;">✨ AI 진료 요약 (Summary)</span>
	                        <textarea id="summaryResult" class="form-control emr-input mt-1" rows="3" readonly style="background-color: #f0fdf4; color: #155724;"></textarea>
                        </div>
	                        <div class="d-flex justify-content-end gap-2 mt-auto pt-3 border-top">
	                        <button type="button" class="btn btn-secondary btn-sm px-3" onclick="resetForm()">초기화</button>
	                        <button type="button" class="btn btn-info btn-sm px-3 text-white" onclick="getSummary()">⚡ AI 요약</button>
	                        <button type="button" id="saveBtn" class="btn btn-primary btn-sm px-4 fw-bold">진료 완료 및 저장</button>
                        </div>

                    </form>
                </div>
            </div>

        </div> 
    </div> 
</div> 

<script>
    // 사이드바 클릭
    function onPatientClick(patientId, waitingId) {
        location.href = "Doctor.jsp?selectId=" + patientId;
    }

    // 과거 기록 불러오기
    function loadHistoryToForm(element) {
        $("#history_id").val($(element).data("id"));
        $("#symptom_detail").val($(element).data("symptom"));
        $("#memo").val($(element).data("memo"));
        $("#bp_systolic").val($(element).data("bpsys"));
        $("#bp_diastolic").val($(element).data("bpdia"));
        $("#temp").val($(element).data("temp"));
        $("#weight").val($(element).data("weight"));
        $("#height").val($(element).data("height")); // 키 추가됨

        $("#saveBtn").text("수정 내용 저장").removeClass("btn-primary").addClass("btn-warning text-white");
        $(".history-card-item").removeClass("bg-primary bg-opacity-10 border-primary"); // 기존 선택 해제
        $(element).addClass("bg-primary bg-opacity-10 border-primary"); // 선택 효과
    }

    // 초기화
    function resetForm() {
        $("#recordForm")[0].reset();
        $("#history_id").val("");
        $("input[name='patient_id']").val("<%= (currentPatient != null) ? currentPatient.getPatientId() : "" %>");
        
        $("#saveBtn").text("진료 완료 및 저장").removeClass("btn-warning text-white").addClass("btn-primary");
        $(".history-card-item").removeClass("bg-primary text-white bg-opacity-10 border-primary");
    }
    
 // [Doctor.jsp 수정] AI 요약 요청 함수
    function getSummary() {
        // 1. 유효성 검사 (입력된 내용이 너무 없으면 경고)
        /*
        if($("#symptom_detail").val().trim() == "" && $("#memo").val().trim() == "") {
            alert("증상이나 진료 소견을 입력한 후 요약을 요청해주세요.");
            return;
        }
        */

        var $btn = $(event.target);
        var originalText = $btn.text();
        
        // 2. 버튼 로딩 상태 변경
        $btn.prop("disabled", true).text("분석 중...");
        
        // 3. JSP Proxy로 데이터 전송 (일반적인 form 데이터 형식)
        $.ajax({
            type: "POST",
            url: "ajax/getSummary.jsp", // 새로 만든 JSP 파일 경로
            data: {
                "height": $("#height").val(),
                "weight": $("#weight").val(),
                "bp_systolic": $("#bp_systolic").val(),
                "bp_diastolic": $("#bp_diastolic").val(),
                "temp": $("#temp").val(),
                "symptom_detail": $("#symptom_detail").val(),
                "memo": $("#memo").val()
            },
            dataType: "json",
            success: function(res) {
                $("#summaryContainer").fadeIn(); // 결과창 부드럽게 표시
                
                // Python 서버에서 주는 키 값에 따라 수정 필요 (여기선 'summary'로 가정)
                // 만약 Python이 {"result": "..."} 로 준다면 res.result 로 변경
                if(res.summary) {
                    $("#summaryResult").val(res.summary);
                } else if(res.message) {
                    $("#summaryResult").val("메시지: " + res.message);
                } else {
                    $("#summaryResult").val("결과: " + JSON.stringify(res));
                }
            },
            error: function(err) {
                console.log(err);
                alert("AI 요약 서버 통신 실패");
            },
            complete: function() {
                // 버튼 원복
                $btn.prop("disabled", false).text(originalText);
            }
        });
    }

    $(document).ready(function() {
        $("#saveBtn").click(function() {
            if ($("input[name='patient_id']").val() == "") {
                alert("환자를 선택해주세요.");
                return;
            }
            $.ajax({
                type: "POST",
                url: "ajax/saveDiagnosis.jsp",
                data: $("#recordForm").serialize(),
                dataType: "json",
                success: function(res) {
                    if (res.success) {
                        alert(res.message);
                        location.reload(); 
                    } else {
                        alert("오류: " + res.message);
                    }
                },
                error: function() { alert("서버 통신 오류"); }
            });
        });
    });
</script>

</body>
</html>