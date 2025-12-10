""" 원래 코드

from search import answer_question

 

# 먼저 메시지 표시하기
print("질문을 입력하세요")

conversation_history = []

while True:
    # 사용자가 입력한 문자를 'user_input' 변수에 저장
    user_input = input()

    # 사용자가 입력한 문자가 'exit'인 경우 루프에서 빠져나옴
    if user_input == "exit":
        break
    
    conversation_history.append({"role": "user", "content": user_input})
    answer = answer_question(user_input, conversation_history)

    print("ChatGPT:", answer)
    conversation_history.append({"role": "assistant", "content":answer})
"""
   

# 변경한 코드
from flask import Flask, request, jsonify
from flask_cors import CORS
from search import answer_question  # 기존 구현된 함수

app = Flask(__name__)
CORS(app)  # 웹사이트와의 통신 허용

conversation_history = []

# [수정된 부분] 무한 반복문(while True) 대신 요청을 기다리는 라우트 생성
@app.route('/chat', methods=['POST'])
def chat():
    # 1. 웹(JSP)에서 보낸 질문 받기 (input() 대체)
    data = request.get_json()
    user_input = data.get('message')

    # 2. 이미 구현된 AI 응답 함수 호출
    answer = answer_question(user_input, conversation_history)

    # 3. 히스토리 저장 (기존 로직 유지)
    conversation_history.append({"role": "assistant", "content": answer})

    # 4. 결과를 JSON 형태로 웹에 반환 (print 대체)
    return jsonify({"response": answer})

if __name__ == '__main__':
    # 5000번 포트에서 서버 실행
    app.run(host='0.0.0.0', port=5000)