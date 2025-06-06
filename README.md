# MT5 BbRsi Expert Advisor

This is a MetaTrader 5 Expert Advisor (EA) that opens simultaneous Buy and Sell positions based on Bollinger Bands and RSI indicator signals. The strategy includes additional trade logic based on price movement, and features advanced risk management options such as trailing stop loss and time-based position closure.

## 🧠 Strategy Logic

- On signal from indicators:
  - Opens **two trades** (Main and Secondary) in opposite directions.
  - Signals are generated based on:
    - Bollinger Bands breakout (Upper or Lower band)
    - RSI crossing above or below predefined overbought/oversold levels
- If price moves a specified number of points **in the direction of the Secondary trade**, a **third trade** is triggered in that direction.
- Optional features:
  - **Trailing Stop Loss** per trade group
  - **Close by time** feature for each trade
  - Full configuration for lot sizes, SL/TP, RSI/BB settings

## ⚙️ Input Parameters

### General Settings
- `magic`: Magic number (used to filter trades)
- `Slippage`: Maximum allowed slippage in points

### Trade Groups
Each of the three trades (Main, Secondary, Second of Secondary) has:
- `lot size`, `StopLoss`, `TakeProfit`
- `StopLossTime`: Time in seconds to auto-close trade (0 = OFF)
- `tsOn`: Enable trailing stop
- `trailingStart`, `trailingProfit`, `trailingStep`: Parameters for trailing logic

### Signal Conditions
- `rsiEntryH`, `rsiEntryL`: RSI levels to trigger entries
- `candle`: Current or previous candle for signal validation
- Bollinger Bands and RSI indicator settings are fully customizable

## 📸 Screenshots

*(Add a screenshot of MetaTrader 5 strategy tester, journal, or positions panel here)*

## 🛠 Technologies Used

- **MetaTrader 5 (MT5)**
- **MQL5**
- Built-in indicators: `iBands`, `iRSI`

## 📂 File Structure

mt5-bbands-rsi-ea/
├── BbRsiEa.mq5
├── README.md
└── screenshots/
└── panel-preview.png


## ✅ Usage Instructions

1. Open MetaEditor in MetaTrader 5
2. Create a new EA named `BbRsiEa.mq5` and paste the code
3. Compile and attach to any chart
4. Adjust input parameters as needed
5. Test in strategy tester or live environment

## 📄 License

MIT or personal use (adjust as needed)

---

## 🙋‍♂️ Author

**Mikhail Krygin**  
Kyiv, Ukraine  
textyping2@gmail.com  
[GitHub Profile](https://github.com/MishaDeveloper)



