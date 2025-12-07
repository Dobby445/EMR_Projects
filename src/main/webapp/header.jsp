<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    HttpSession usersession = request.getSession();
    String userName = (String) usersession.getAttribute("userName");
    Boolean isLoggedIn = (Boolean) usersession.getAttribute("isLoggedIn");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>비트CARE+</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
  <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
  
  <link rel="stylesheet" href="CSS/style.css">
  <link rel="stylesheet" href="CSS/header.css">
  
  <script>
      const contextPath = "${pageContext.request.contextPath}";
  </script>
  <script src="js/headerSearch.js"></script>
</head>
<body>

  <nav class="navbar navbar-expand-lg navbar-dark px-3 navbar-custom">
    <div class="container-fluid">
      <a class="navbar-brand d-flex align-items-center" href="main.jsp">
        <img src="images/로고.png" alt="로고" style="height: 40px; margin-right: 10px;">
        <span class="fw-bold">비트CARE+</span>
      </a>
      <div class="collapse navbar-collapse">
        <ul class="navbar-nav me-auto mb-2">
          <li class="nav-item"><a class="nav-link" href="main.jsp">Home</a></li>
          <li class="nav-item"><a class="nav-link" href="Nurse.jsp">Nurse</a></li>
          <li class="nav-item"><a class="nav-link" href="Doctor.jsp">Doctor</a></li>
          <li class="nav-item"><a class="nav-link" href="notice.jsp">공지사항</a></li>
        </ul>

        <div class="search-container d-flex me-3 position-relative">
            <input id="headerSearchInput" class="form-control" type="text" placeholder="환자명 또는 ID 검색..." autocomplete="off">
            <div id="search-results"></div>
        </div>

        <div class="d-flex align-items-center">
          <% if (isLoggedIn != null && isLoggedIn) { %>
              <span class="navbar-text me-3 text-white">환영합니다, <%= userName %>님!</span>
              <a href="logout.jsp" class="btn btn-sm btn-outline-light">LogOut</a>
          <% } else { %>
              <a href="Login_Doctor.jsp" class="btn btn-sm btn-outline-light me-2">로그인</a>
              <a href="join.jsp" class="btn btn-sm btn-outline-warning">회원가입</a>
          <% } %>
        </div>
      </div>
    </div>
  </nav>

  <div id="chatbot-window">
      <div class="chat-header">
          <span>비트CARE+ 도우미</span>
          <span style="cursor: pointer;" onclick="toggleChatbot()">✖</span>
      </div>
      <div class="chat-body">
          <div style="background: white; padding: 8px 12px; border-radius: 10px; display: inline-block; box-shadow: 0 1px 2px rgba(0,0,0,0.1);">
              안녕하세요! 궁금한 점을 물어보세요.
          </div>
      </div>
      <div class="chat-input-area">
          <input type="text" placeholder="메시지 입력...">
          <button class="btn btn-dark btn-sm">전송</button>
      </div>
  </div>

  <div id="btn-aitutor-open-aiTutor" onclick="toggleChatbot()">
      <svg stroke="currentColor" fill="none" stroke-width="2" viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round" height="1em" width="1em" xmlns="http://www.w3.org/2000/svg">
          <path stroke="none" d="M0 0h24v24H0z" fill="none"></path>
          <path d="M4 21v-13a3 3 0 0 1 3 -3h10a3 3 0 0 1 3 3v6a3 3 0 0 1 -3 3h-9l-4 4"></path>
          <path d="M9.5 9h.01"></path>
          <path d="M14.5 9h.01"></path>
          <path d="M9.5 13a3.5 3.5 0 0 0 5 0"></path>
      </svg>
  </div>

  <script>
      function toggleChatbot() {
          const chatWindow = document.getElementById("chatbot-window");
          if (chatWindow.style.display === "none" || chatWindow.style.display === "") {
              chatWindow.style.display = "flex";
          } else {
              chatWindow.style.display = "none";
          }
      }
  </script>