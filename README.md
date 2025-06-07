# MT5 BbRsi Expert Advisor

This is a MetaTrader 5 Expert Advisor (EA) that opens simultaneous Buy and Sell positions based on Bollinger Bands and RSI indicator signals. The strategy includes additional trade logic based on price movement, and features advanced risk management options such as trailing stop loss and time-based position closure.

---

## 🧠 Strategy Logic

- On signal from indicators:
  - Opens **two trades** (Main and Secondary) in opposite directions.
  - Signals are generated based on:
    - Bollinger Bands breakout (Upper or Lower band)
    - RSI crossing above or below predefined overbought/oversold levels
- If price moves a specified number of points **in the direction of the Secondary trade**, a **third trade** is triggered in that direction.
- Optional features:
  - Trailing Stop Loss per trade group
  - Close by time feature for each trade
  - Full configuration for lot sizes, SL/TP, RSI/BB settings

---

## ⚙️ Input Parameters

### 🔹 General Settings
- `magic`: Magic number (used to filter trades)
- `Slippage`: Maximum allowed slippage in points

### 🔹 Trade Groups
Each of the three trades (Main, Secondary, Second of Secondary) has:
- `lot size`, `StopLoss`, `TakeProfit`
- `StopLossTime`: Time in seconds to auto-close trade (0 = OFF)
- `tsOn`: Enable trailing stop
- `trailingStart`, `trailingProfit`, `trailingStep`: Trailing stop logic

### 🔹 Signal Conditions
- `rsiEntryH`, `rsiEntryL`: RSI levels to trigger entries
- `candle`: Use current or previous candle for signal
- Bollinger Bands and RSI indicator settings are customizable

---

## 📸 Screenshot

[Backtesting results](screenshots/panel-preview.png)

---

## 🛠 Technologies Used

- MetaTrader 5 (MT5)
- MQL5
- Built-in indicators: `iBands`, `iRSI`

---

## 📂 File Structure

mt5-bbands-rsi-ea/

├── BbRsiEa.mq5

├── README.md

└── screenshots/

└── panel-preview.png


---

## ✅ Usage Instructions

1. Open **MetaEditor** in MetaTrader 5
2. Create a new EA file named `BbRsiEa.mq5`
3. Paste and compile the code
4. Attach the EA to any chart
5. Adjust input parameters
6. Run in **Strategy Tester** or **Live Trading**

---

## 📄 License

MIT License (or personal use — optional to specify)

---

## 🙋‍♂️ Author

**Mikhail Krygin**  
📍 Kyiv, Ukraine  
📧 [textyping2@gmail.com](mailto:textyping2@gmail.com)  
🔗 [GitHub Profile](https://github.com/MishaDeveloper)

