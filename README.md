# MIZAR Protocol Buffers

MIZAR 交易系統的多語言協定中心，專門用來集中管理所有跨專案、跨語言通用的 Protobuf (.proto) 檔案。

## 專案結構

```
mizar-proto/
├── README.md                 # 專案說明
├── mizar-proto.md           # 詳細規範說明
├── roadmap.md               # 開發路線圖
├── compile.ps1              # PowerShell 編譯工具
├── publish.ps1              # PowerShell 發布工具

├── compiler/                # Protocol Buffers 編譯器
│   └── bin/
│       ├── linux64/         # Linux 64位元版本
│       │   └── protoc
│       └── win64/           # Windows 64位元版本
│           └── protoc.exe
├── proto/                   # Proto 檔案目錄
│   ├── mizar_common.proto   # 通用協定（錯誤代碼、ENUM、共用 MESSAGE）
│   ├── mizar_info.proto     # 基本資訊協定（商品檔、帳號資訊）
│   ├── mizar_quote.proto    # 報價相關協定（訂閱、歷史資料、市場快照）
│   ├── mizar_portfolio.proto # 帳務相關協定（保證金、持倉查詢）⭐ 最新完成
│   ├── mizar_stream.proto   # 串流資料協定（事件通知、回報、即時行情）
│   └── mizar_trade.proto    # 交易相關協定（下單、改單、刪單）⭐ 最新完成
├── go/                      # Go 語言編譯輸出
│   ├── .gitkeep            # 確保目錄被 Git 追蹤
│   └── *.pb.go             # 編譯後的 Go 檔案
└── python/                  # Python 編譯輸出
    ├── .gitkeep            # 確保目錄被 Git 追蹤
    └── *_pb2.py            # 編譯後的 Python 檔案
```

## 快速開始

### 1. 開發環境設置

編譯工具會自動檢查並設置環境：

```powershell
.\compile.ps1
```

### 2. 本地編譯

```powershell
.\compile.ps1
```

### 3. 編譯測試

在發布前，建議先進行編譯測試：

```powershell
.\compile.ps1
```

### 4. 發布版本

當你準備發布新版本時：

```powershell
.\publish.ps1
```

發布流程會自動：
1. **檢查未提交變更**：如果有未 commit 的檔案會提示先手動 commit
2. **自動遞增版本號**：第三位版本號自動 +1（如 v1.0.0 → v1.0.1）
3. 執行編譯測試
4. 編譯到正式目錄
5. 提交編譯結果
6. 建立 tag
7. Push 到遠端


### 5. 使用編譯後的檔案

#### Go 語言
```go
package main

import (
    "github.com/honeymagico/mizar-proto/go"
    "google.golang.org/protobuf/proto"
)

func main() {
    // 建立報價訂閱請求
    subscribe := &mizar_quote.SubscribeQuoteRequest{
        ContractCode: "2330",
        QuoteType: mizar_quote.QuoteType_QUOTE_TYPE_TICK,
    }
    
    // 序列化
    data, err := proto.Marshal(subscribe)
    if err != nil {
        panic(err)
    }
    
    // 反序列化
    var newSubscribe mizar_quote.SubscribeQuoteRequest
    err = proto.Unmarshal(data, &newSubscribe)
    if err != nil {
        panic(err)
    }
}
```

#### Python
```python
import mizar_quote_pb2

# 建立報價訂閱請求
subscribe = mizar_quote_pb2.SubscribeQuoteRequest(
    contract_code="2330",
    quote_type=mizar_quote_pb2.QuoteType.QUOTE_TYPE_TICK
)

# 序列化
data = subscribe.SerializeToString()

# 反序列化
new_subscribe = mizar_quote_pb2.SubscribeQuoteRequest()
new_subscribe.ParseFromString(data)
```

**注意**：使用生成的 Python 檔案時，需要安裝 `protobuf` 套件：
```bash
pip install protobuf>=4.21.0
```

## 協定說明

### mizar_common.proto
通用協定，包含：
- **錯誤代碼定義**：標準化錯誤處理
- **買賣方向**：Action ENUM（買/賣）
- **價格類型**：PriceType ENUM（限價/市價/範圍市價）
- **委託類別**：OrderType ENUM（ROD/IOC/FOK）
- **委託性質**：OcType ENUM（自動/新倉/平倉/當沖）
- **委託狀態**：OrderStatus ENUM（完整狀態定義）
- **行情相關**：TickType、ChangeType、SimTradeType ENUM
- **資料回傳狀態**：FetchStatus ENUM
- **共用 MESSAGE**：Deal、OrderStatusInfo、Order、Contract、Trade

### mizar_info.proto
基本資訊協定，包含：
- **交易所類型**：Exchange ENUM（TSE/OTC/OES）
- **當沖類型**：DayTrade ENUM
- **選擇權權利類型**：OptionRight ENUM
- **合約類型**：ContractType ENUM
- **帳號資訊**：FutureAccount
- **商品檔**：Stock、Future、Option、Index 合約資訊
- **查詢功能**：GetFutureAccount、GetContract

### mizar_quote.proto
**報價相關協定**，包含：
- **即時報價訂閱**：TICK、BIDASK、QUOTE 三種報價類型
- **歷史資料查詢**：TICK 與 KBAR 歷史資料，陣列格式高效傳輸
- **市場快照**：未訂閱商品的即時市場狀況，適合資金流向分析
- **或有券源**：融券可用性查詢，判斷市場多空情緒
- **資券餘額**：融資融券餘額，分析市場資金流向

### mizar_portfolio.proto
**帳務相關協定**，包含：
- **保證金查詢**：GetMarginRequest/Response，完整保證金資訊（原始保證金、維持保證金、可用保證金、權益數等）
- **期貨持倉列表**：GetFuturePositionListRequest/Response，查詢所有期貨持倉
- **期貨持倉明細**：GetFuturePositionDetailRequest/Response，查詢特定持倉的詳細交易記錄
- **資料結構**：MarginInfo、FuturePosition、FuturePositionDetail

### mizar_stream.proto
**串流資料協定**，包含：
- **系統事件通知**：SystemEvent，系統上線/下線事件，直接發送到 MQ TOPIC
- **期貨交易回報**：FutureOrderReport、FutureDealReport，委託回報與成交回報
- **股票即時行情**：StockTick 與 StockBidAsk，完整覆蓋股票市場資料
- **期貨即時行情**：FutureTick 與 FutureBidAsk，包含標的物價格與衍生委託
- **操作資訊**：Operation，記錄操作類型與結果

### mizar_trade.proto
**交易相關協定**，包含：
- **期貨下單**：FuturePlaceOrderRequest/Response，完整下單功能
- **期貨改單**：FutureUpdateOrderRequest/Response，支援改價、改量、改類型
- **期貨刪單**：FutureCancelOrderRequest/Response，安全刪單機制
- **委託狀態查詢**：GetOrderStatusRequest/Response，查詢所有委託狀態
- **完整交易資訊**：回傳 Trade 物件，包含 Contract、Order、OrderStatusInfo

## 授權宣告

# ⚠️ 私有軟體，嚴禁未經授權存取、使用、散布、修改、公開、衍生、商業行為 ⚠️

**本專案為私人專用軟體，未經明確書面授權，任何人不得以任何形式存取、使用、複製、修改、散布、公開、發佈、衍生、商業利用本專案之全部或部分內容。**

- 本專案不對外公開、不對外授權、不允許任何第三方取得或使用。
- 嚴禁將本專案內容用於任何商業、學術、公開或衍生用途。
- 違反者將依法追究相關法律責任。

**Copyright © 2024 All rights reserved.**


