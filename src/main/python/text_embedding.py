import pandas as pd
import tiktoken
from openai import OpenAI
import re

client = OpenAI(api_key="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")

# ==============================================
# 설정
# ==============================================
embedding_model = "text-embedding-3-small"
embedding_encoding = "cl100k_base"
max_tokens = 2000  

# ==============================================
# 1) 데이터 로드
# ==============================================
df = pd.read_csv("merged_dataset.csv")
print(f"원본 데이터 크기: {len(df)} 행")

# ==============================================
# 2) 텍스트 전처리 함수
# ==============================================
def preprocess_text(text):
    """
    텍스트 정제 및 전처리
    - 중복 공백 제거
    - 특수문자 정리
    - 의료 용어 표준화
    """
    if pd.isna(text) or text == "":
        return ""
    
    text = str(text)
    
    # 중복 공백 제거
    text = re.sub(r'\s+', ' ', text)
    
    # 불필요한 특수문자 제거 (의료 기호는 보존)
    text = re.sub(r'[^\w\s\.,!?~°%\-/()]', '', text)
    
    # 의료 용어 동의어 추가 (검색 향상을 위해)
    medical_synonyms = {
        '두통': ['두통', '머리아픔', '두부통증'],
        '발열': ['발열', '열', '고열', '체온상승'],
        '기침': ['기침', '해수', '가래'],
        '복통': ['복통', '배아픔', '복부통증'],
        '설사': ['설사', '묽은변', '물설사'],
    }
    
    # 동의어 확장 (원본 유지 + 동의어 추가)
    for key, synonyms in medical_synonyms.items():
        if key in text:
            text += f" [{'/'.join(synonyms)}]"
    
    return text.strip()

# ==============================================
# 3) 여러 컬럼을 하나의 텍스트로 병합
# ==============================================
df = df.fillna("")

# 각 행의 모든 컬럼을 구분자로 연결
# 개선점: 컬럼명도 포함하여 구조화된 텍스트 생성
def create_structured_text(row):
    """컬럼명과 값을 함께 포함하여 구조화된 텍스트 생성"""
    parts = []
    for col_name, value in row.items():
        if value and str(value).strip():
            parts.append(f"{col_name}: {preprocess_text(str(value))}")
    return " | ".join(parts)

df["text"] = df.apply(create_structured_text, axis=1)

# title은 첫 번째 컬럼 사용
df["title"] = df.iloc[:, 0].astype(str).apply(preprocess_text)

# 필요한 컬럼만 유지
df = df[["title", "text"]]

# 빈 텍스트 제거
df = df[df["text"].str.strip() != ""]
print(f"전처리 후 데이터 크기: {len(df)} 행")

# ==============================================
# 4) Token 계산
# ==============================================
tokenizer = tiktoken.get_encoding(embedding_encoding)
df['n_tokens'] = df.text.apply(lambda x: len(tokenizer.encode(str(x))))

print(f"평균 토큰 수: {df['n_tokens'].mean():.0f}")
print(f"최대 토큰 수: {df['n_tokens'].max()}")
print(f"토큰 초과 행 수: {len(df[df['n_tokens'] > max_tokens])}")

# ==============================================
# 5) 토큰 초과 시 청크 분리 함수 (개선)
# ==============================================
def split_into_many(text, max_tokens=500):
    """
    개선된 청크 분리 함수:
    - 문장 단위 분리
    - 의미 단위 보존
    - 오버랩 추가 (컨텍스트 보존)
    """
    # 여러 구분자로 문장 분리
    sentences = re.split(r'[.!?]\s+|\n+|\|', text)
    sentences = [s.strip() for s in sentences if s.strip()]
    
    n_tokens = [len(tokenizer.encode(sentence)) for sentence in sentences]
    
    chunks = []
    tokens_so_far = 0
    chunk = []
    
    for sentence, token in zip(sentences, n_tokens):
        # 현재 청크에 추가하면 초과하는 경우
        if tokens_so_far + token > max_tokens:
            if chunk:
                chunks.append(". ".join(chunk) + ".")
            
            # 새 청크 시작 (오버랩을 위해 마지막 문장 포함)
            if len(chunk) > 0:
                chunk = [chunk[-1], sentence]  # 마지막 문장을 다음 청크에도 포함
                tokens_so_far = n_tokens[-1] + token
            else:
                chunk = [sentence]
                tokens_so_far = token
        else:
            chunk.append(sentence)
            tokens_so_far += token + 1
        
        # 단일 문장이 max_tokens를 초과하는 경우 단어 단위로 분리
        if token > max_tokens:
            words = sentence.split()
            temp_chunk = []
            temp_tokens = 0
            
            for word in words:
                word_tokens = len(tokenizer.encode(word))
                if temp_tokens + word_tokens > max_tokens:
                    if temp_chunk:
                        chunks.append(" ".join(temp_chunk))
                    temp_chunk = [word]
                    temp_tokens = word_tokens
                else:
                    temp_chunk.append(word)
                    temp_tokens += word_tokens
            
            if temp_chunk:
                chunks.append(" ".join(temp_chunk))
            
            chunk = []
            tokens_so_far = 0
    
    # 남은 청크 추가
    if chunk:
        chunks.append(". ".join(chunk) + ".")
    
    return chunks

# ==============================================
# 6) 청크 조정 수행
# ==============================================
shortened = []

for idx, row in df.iterrows():
    text = row["text"]
    title = row["title"]
    
    if text is None or text.strip() == "":
        continue
    
    if row["n_tokens"] > max_tokens:
        # 긴 텍스트는 청크로 분리
        chunks = split_into_many(text, max_tokens)
        for i, chunk in enumerate(chunks):
            # 각 청크에 title 정보 추가 (검색 향상)
            shortened.append({
                "title": f"{title} (part {i+1}/{len(chunks)})",
                "text": f"[{title}] {chunk}"
            })
    else:
        shortened.append({
            "title": title,
            "text": f"[{title}] {text}"
        })

df = pd.DataFrame(shortened)
df["n_tokens"] = df.text.apply(lambda x: len(tokenizer.encode(str(x))))

print(f"\n청크 분리 후 데이터 크기: {len(df)} 행")
print(f"평균 토큰 수: {df['n_tokens'].mean():.0f}")
print(f"최대 토큰 수: {df['n_tokens'].max()}")

# ==============================================
# 7) Embedding 생성
# ==============================================
def get_embedding(text, model):
    """임베딩 생성 함수 (에러 처리 추가)"""
    try:
        text = text.replace("\n", " ")
        return client.embeddings.create(input=[text], model=model).data[0].embedding
    except Exception as e:
        print(f"임베딩 생성 오류: {e}")
        return None

print("\n임베딩 생성 중...")
df["embeddings"] = df.text.apply(lambda x: get_embedding(x, embedding_model))

# None 값 제거
df = df[df["embeddings"].notna()]
print(f"최종 데이터 크기: {len(df)} 행")

# ==============================================
# 8) 저장
# ==============================================
df.to_csv("embeddings.csv", index=False)
print("\n 생성 완료: embeddings.csv")

