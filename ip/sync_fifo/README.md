
## Overview
Synchronous FIFO with Parameterized Depth/Width
Block Diagram:

## Interface & Parameters
Parameters: DATA_WIDTH, FIFO_DEPTH 등 가변 인자 설명.

Signals: 각 포트의 의미와 Active High/Low 여부.

## Key Features & Design Detail
이 부분이 가장 중요합니다. 본인이 고민한 흔적을 적으세요.

Status Logic: 질문하신 phase 비트나 wrap-around를 이용해 Full/Empty를 어떻게 판별했는지 설명.

Pointer Management: Binary 카운터를 썼는지, 포인터 업데이트 조건은 무엇인지.

Read/Write Policy: 예를 들어, "Full일 때 쓰기 요청이 오면 무시함(Drop)" 혹은 "Empty일 때 읽기 요청이 오면 무시함" 같은 정책을 명시합니다.

2. Testbench(TB) 시나리오 구성
간단한 확인용이라면 최소한 아래 4단계 시나리오는 포함되어야 "검증 좀 할 줄 아는구나"라는 인상을 줍니다.

Basic Read/Write: 데이터가 깨지지 않고 순서대로(First-In, First-Out) 잘 나오는지 확인.

Full/Empty Boundary:

FIFO가 가득 찰 때까지 계속 쓰고, full 신호가 뜨는지 확인.

가득 찬 상태에서 한 번 더 썼을 때 데이터가 오버라이트 되지 않는지(Overflow 방지).

반대로 완전히 비우고 empty 확인.

Simultaneous Read/Write:

쓰기와 읽기를 동시에 수행할 때 포인터와 카운터가 안정적인지 확인.

특히 FIFO가 1개만 남았을 때 동시에 읽고 쓰면 어떻게 되는지 등.

Reset/Random: 동작 중간에 Reset을 걸었을 때 모든 포인터가 초기화되는지, 그리고 무작위로 읽고 쓰기를 반복(Randomized stress test)했을 때 데이터 누수가 없는지 확인


// Basic Read/Write: 데이터가 깨지지 않고 순서대로(First-In, First-Out) 잘 나오는지 확인.
//
//Testbench List: 
//  1. Full/Empty Boundary: 
//  - FIFO가 가득 찰 때까지 계속 쓰고, full 신호가 뜨는지 확인.
//  - 가득 찬 상태에서 한 번 더 썼을 때 데이터가 오버라이트 되지 않는지(Overflow 방지).
//  - 반대로 완전히 비우고 empty 확인.
//
// 2. Simultaneous Read/Write:
//  - 쓰기와 읽기를 동시에 수행할 때 포인터와 카운터가 안정적인지 확인.
//  - 특히 FIFO가 1개만 남았을 때 동시에 읽고 쓰면 어떻게 되는지 등.
// 3. Reset/Random: 
//  - 동작 중간에 Reset을 걸었을 때 모든 포인터가 초기화되는지
//  - 무작위로 읽고 쓰기를 반복(Randomized stress test)했을 때 데이터 누수가 없는지 확인.
