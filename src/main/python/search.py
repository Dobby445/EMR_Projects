import pandas as pd
from openai import OpenAI
import numpy as np
from typing import List
from scipy import spatial

client = OpenAI(api_key="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")

def distances_from_embeddings(
    query_embedding: List[float],
    embeddings: List[List[float]],
    distance_metric="cosine",
) -> List[List]:
    """Return the distances between a query embedding and a list of embeddings."""
    distance_metrics = {
        "cosine": spatial.distance.cosine,
        "L1": spatial.distance.cityblock,
        "L2": spatial.distance.euclidean,
        "Linf": spatial.distance.chebyshev,
    }
    distances = [
        distance_metrics[distance_metric](query_embedding, embedding)
        for embedding in embeddings
    ]
    return distances

def preprocess_question(question):
    """
    질문 전처리: 의료 용어 동의어 확장
    """
    # 의료 용어 동의어 사전
    medical_synonyms = {
        '아파요': ['통증', '아픔', '불편함'],
        '아픈': ['통증', '아픔'],
        '열': ['발열', '고열', '체온상승'],
        '기침': ['해수', '가래'],
        '두통': ['머리아픔', '두부통증'],
        '복통': ['배아픔', '복부통증'],
        '설사': ['묽은변', '물설사'],
        '감기': ['상기도감염', '독감'],
        '어지러움': ['현기증', '어지럽다'],
        '구토': ['토하다', '구역질', '메스꺼움'],
    }
    
    expanded_terms = [question]
    
    # 동의어 확장
    for key, synonyms in medical_synonyms.items():
        if key in question:
            expanded_terms.extend(synonyms)
    
    # 결합
    expanded_query = " ".join(expanded_terms)
    return expanded_query

def create_context(question, df, max_len=3000):
    """
    질문과 학습 데이터를 비교해 컨텍스트를 만드는 함수
    개선: max_len을 1800 -> 3000으로 증가, 질문 전처리 추가
    """
    
    # 질문 전처리 및 확장
    expanded_question = preprocess_question(question)

    # 질문을 벡터화
    q_embeddings = client.embeddings.create(input=[expanded_question], model='text-embedding-3-small').data[0].embedding

    # 질문과 학습 데이터와 비교하여 코사인 유사도를 계산하고
    # 'distances' 열에 유사도를 저장
    df['distances'] = distances_from_embeddings(q_embeddings, df['embeddings'].apply(eval).apply(np.array).values, distance_metric='cosine')
    
    # 컨텍스트를 저장하기 위한 리스트
    returns = []
    # 컨텍스트의 현재 길이
    cur_len = 0

    # 학습 데이터를 유사도 순으로 정렬하고 토큰 개수 한도까지 컨텍스트에 추가
    for _, row in df.sort_values('distances', ascending=True).iterrows():
        # 텍스트 길이를 현재 길이에 더하기
        cur_len += row['n_tokens'] + 4

        # 텍스트가 너무 길면 루프 종료
        if cur_len > max_len:
            break

        # 컨텍스트 목록에 텍스트 추가하기
        returns.append(row["text"])

    # 컨텍스트를 결합해 반환
    return "\n\n###\n\n".join(returns)

def answer_question(question, conversation_history):
    """
    문맥에 따라 질문에 답하는 기능
    개선: 더 나은 프롬프트, temperature 조정
    """

    # 학습 데이터 불러오기
    df = pd.read_csv('embeddings.csv')

    context = create_context(question, df, max_len=3000)  # ← max_len을 200 -> 3000으로 증가
    
    # 프롬프트를 생성하고 대화 기록에 추가하기
    prompt = f"""당신은 전문 의료 상담 AI입니다. 다음 역할을 수행하세요:

1. 제공된 의료 컨텍스트를 기반으로 정확하게 답변
2. 컨텍스트에 없는 정보는 "제공된 자료에는 해당 정보가 없습니다"라고 명시
3. 의료 조언이 필요한 경우 반드시 "전문의 상담을 권장합니다" 추가
4. 친절하고 이해하기 쉬운 언어 사용
5. 유사한 증상이나 관련 정보가 있다면 함께 안내

주의사항:
- 진단이나 처방을 직접 하지 않음
- 응급 상황 시 즉시 병원 방문 권고
- 불확실한 정보는 추측하지 않음

컨텍스트: {context}

---

질문: {question}
답변:"""
    
    conversation_history.append({"role": "user", "content": prompt})

    try:
        # ChatGPT에서 답변 생성
        response = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=conversation_history,
            temperature=0.3,  # 1 -> 0.3으로 변경 (더 일관된 답변)
        )

        # ChatGPT에서 답변 반환
        return response.choices[0].message.content.strip()
    except Exception as e:
        # 오류가 발생하면 빈 문자열을 반환
        print(e)
        return ""