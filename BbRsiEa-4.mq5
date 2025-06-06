//+------------------------------------------------------------------+
//|                                                      BbRsiEa.mq5 |
//|                                                             Mike |
//|                                             textyping2@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Mike"
#property link      "textyping2@gmail.com"
#property version   "1.00"

enum candleEnum
  {
   current  = 0,                 // Currently Opened
   closed   = 1,                 // Last Closed
  };
  
input string                     stage1            = "===== General Settings =====";         // ================================
input int                        magic             = 168737;                                 // Magic Number                                  
input int                        Slippage          = 100;

input string                     stage2            = "===== Main Asset Settings =====";      // ================================
input double                     lot1              = 1;                                      // Lot Size
input double                     StopLoss1         = 0;                                      // Stop Loss, Points (0 - OFF)
input int                        StopLossTime1     = 0;                                      // Stop Loss, Seconds (0 - OFF)
input double                     TakeProfit1       = 0;                                      // Take Profit, Points (0 - OFF)
input bool                       tsOn1             = false;                                  // Trailing Stop Loss ON
input double                     trailingStart1    = 100;                                    // Trailing Stop Start, Points
input double                     trailingProfit1   = 50;                                     // Trailing Stop Profit, Points
input double                     trailingStep1     = 1;                                      // Trailing Stop Step, Points

input string                     stage3            = "===== Secondary Asset Settings ====="; // ================================
input double                     lot2              = 1;                                      // Lot Size
input double                     StopLoss2         = 0;                                      // Stop Loss, Points (0 - OFF)
input int                        StopLossTime2     = 0;                                      // Stop Loss, Seconds (0 - OFF)
input double                     TakeProfit2       = 0;                                      // Take Profit, Points (0 - OFF)
input bool                       tsOn2             = false;                                  // Trailing Stop Loss ON

input double                     trailingStart2    = 100;                                    // Trailing Stop Start, Points
input double                     trailingProfit2   = 50;                                     // Trailing Stop Profit, Points
input double                     trailingStep2     = 1;                                      // Trailing Stop Step, Points

input string                     stage31           = "===== Second trade of Secondary Asset Settings ====="; // ================================
input double                     open2             = 0;                                      // Open second trade after passing, Points (0 - OFF)
input double                     lot3              = 1;                                      // Lot Size
input double                     StopLoss3         = 0;                                      // Stop Loss, Points (0 - OFF)
input int                        StopLossTime3     = 0;                                      // Stop Loss, Seconds (0 - OFF)
input double                     TakeProfit3       = 0;                                      // Take Profit, Points (0 - OFF)
input bool                       tsOn3             = false;                                  // Trailing Stop Loss ON

input double                     trailingStart3    = 100;                                    // Trailing Stop Start, Points
input double                     trailingProfit3   = 50;                                     // Trailing Stop Profit, Points
input double                     trailingStep3     = 1;                                      // Trailing Stop Step, Points

input string                     stage4            = "===== Entry Conditions =====";         // ================================
input candleEnum                 candle            = current;                                // Candle for Signal
input double                     rsiEntryH         = 75;                                     // Entry Level High
input double                     rsiEntryL         = 25;                                     // Entry Level Low

input string                     stage5            = "===== Bollinger Bands Indicator's parameters =====";     // ================================
input ENUM_TIMEFRAMES            bbTf              = PERIOD_CURRENT;                         // Time Frame
input int                        bbPeriod          = 20;                                     // Period
input int                        bbShift           = 0;                                      // Shift
input double                     bbDeviation       = 2;                                      // Deviations
input ENUM_APPLIED_PRICE         bbPrice           = PRICE_CLOSE;                            // Type of Price

input string                     stage6            = "===== RSI Indicator's parameters =====";                 // ================================
input ENUM_TIMEFRAMES            rsiTf             = PERIOD_CURRENT;                         // Time Frame
input int                        rsiPeriod         = 14;                                     // Period
input ENUM_APPLIED_PRICE         rsiPrice          = PRICE_CLOSE;                            // Type of Price

int      handleBb, handleRsi;

datetime timeCur;

double   _point,  pipsMultiplier, Ask, Bid, price2sell, price2buy;

string   comment1, comment2, comment3;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   timeCur = 0;
   comment1 = "Main Asset";
   comment2 = "Secondary Asset";
   comment3 = "Second Trade";
   
   _point = _Point;
   pipsMultiplier = 1;
   price2sell = price2buy = 0;
   
   handleBb = iBands (_Symbol, bbTf, bbPeriod, bbShift, bbDeviation, bbPrice);
   handleRsi = iRSI (_Symbol, rsiTf, rsiPeriod, rsiPrice);
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   calculateAskBid();
   
   if (openedPositions())
    {
     if (open2 > 0)
      {
       if (price2buy > 0 && Ask >= price2buy)
        {
         openBuy (lot3, StopLoss3, TakeProfit3, comment3);
         price2buy = 0;
        }
       if (price2sell > 0 && Bid <= price2sell)
        {
         openSell (lot3, StopLoss3, TakeProfit3, comment3);
         price2sell = 0;
        }
      }
    
     if (tsOn1) trailingStop (trailingStart1, trailingProfit1, trailingStep1, comment1);
     if (tsOn2) trailingStop (trailingStart2, trailingProfit2, trailingStep2, comment2);
     if (tsOn3) trailingStop (trailingStart3, trailingProfit3, trailingStep3, comment3);
     
     if (StopLossTime1 > 0) closeByTime (comment1, StopLossTime1);
     if (StopLossTime2 > 0) closeByTime (comment2, StopLossTime2);
     if (StopLossTime3 > 0) closeByTime (comment3, StopLossTime3);
    }
   else
    {
     price2sell = price2buy = 0;
    } 
   
// Initial trade
   if (candle == current || timeCur != iTime (_Symbol, PERIOD_CURRENT, 0))
    {
     timeCur = iTime (_Symbol, PERIOD_CURRENT, 0);
     
     if (!openedPositions())
      {
       double bbUpper = getIndicatorValue (handleBb, UPPER_BAND, candle);
       double bbLower = getIndicatorValue (handleBb, LOWER_BAND, candle);
       
       double candleHigh = iHigh (_Symbol, bbTf, candle);
       double candleLow = iLow (_Symbol, bbTf, candle);
       
       if (candleHigh > bbUpper)
        {
         double rsiValue = getIndicatorValue (handleRsi, 0, candle);
         
         if (rsiValue >= rsiEntryH)
          {
           openSell (lot1, StopLoss1, TakeProfit1, comment1);
           openBuy (lot2, StopLoss2, TakeProfit2, comment2);
           if (open2 > 0) price2buy = Ask + open2 * _Point;
          }
        }
         
       if (candleLow < bbLower)
        {
         double rsiValue = getIndicatorValue (handleRsi, 0, candle);
         
         if (rsiValue <= rsiEntryL)
          {
           openBuy (lot1, StopLoss1, TakeProfit1, comment1);
           openSell (lot2, StopLoss2, TakeProfit2, comment2);
           if (open2 > 0) price2sell = Bid - open2 * _Point;
          }
        }
      }
    }
  }
  
//+------------------------------------------------------------------+ 

bool openedPositions()
  {
   bool z = false;
   if (PositionsTotal() == 0) z = false;
   else
    {
     string deal_symbol = "";
     long deal_magic = 0;

     for (int i = PositionsTotal() - 1; i >= 0; i--)
      {
       deal_symbol = PositionGetSymbol(i);
       deal_magic = PositionGetInteger(POSITION_MAGIC);
       
       if (deal_symbol == _Symbol && deal_magic == magic)
        {
         z = true; 
         break;
        }
      }
    }
   return(z);
  }

//--------------------------------------------------------------------

double getIndicatorValue (int indHandle, int indBuffer, int indShift)
 {
  double res[1];
  
  if (CopyBuffer (indHandle, indBuffer, indShift, 1, res) != 1) 
   {
    return 0;
   }
   
  return res[0];
 }

//+------------------------------------------------------------------+ 

void trailingStop (double trailingStart, double trailingProfit, double trailingStep, string comment)
 {
  if (PositionsTotal() == 0) return;
  ulong ticket;
  string deal_symbol = "";
  long deal_magic = 0;
  ENUM_POSITION_TYPE deal_type;
  double volume;
  string deal_comment;
  
  for (int i = PositionsTotal() - 1; i >= 0; i--)
   {
    deal_symbol = PositionGetSymbol(i);
    ticket = PositionGetInteger (POSITION_TICKET);
    deal_magic = PositionGetInteger (POSITION_MAGIC);
    deal_comment = PositionGetString (POSITION_COMMENT);
    if (deal_magic != magic) continue;
    if (deal_symbol != _Symbol) continue;
    if (deal_comment != comment) continue;
    
    volume = PositionGetDouble (POSITION_VOLUME);
    deal_type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
    double orderClose = PositionGetDouble (POSITION_PRICE_CURRENT);
    double orderSL = PositionGetDouble (POSITION_SL);
    double orderOpen = PositionGetDouble (POSITION_PRICE_OPEN);
    double orderTP = PositionGetDouble (POSITION_TP);
    
    
    if(deal_type == POSITION_TYPE_BUY)
     {
      if (orderClose - orderOpen > trailingStart * _Point)
       {
        double newSL = NormalizeDouble (orderClose - trailingProfit * _Point, _Digits);
        
        if (orderSL == 0 || newSL - orderSL > trailingStep * _Point)
         {
          MqlTradeRequest request = {};
          MqlTradeResult  result = {};
            
          request.action    = TRADE_ACTION_SLTP; 
          request.position  = ticket;            
          request.symbol    = deal_symbol;         
          request.sl        = newSL;            
          request.tp        = orderTP;               
          request.magic     = magic; 
          int Ans = OrderSend(request,result);
         }
       }
     }
    if(deal_type == POSITION_TYPE_SELL)
     {
      if (orderOpen - orderClose > trailingStart * _Point)
       {
        double newSL = NormalizeDouble (orderClose + trailingProfit * _Point, _Digits);
       
        if (orderSL == 0 || orderSL - newSL > trailingStep * _Point)
         {
          MqlTradeRequest request = {};
          MqlTradeResult  result = {};
          
          request.action    = TRADE_ACTION_SLTP; 
          request.position  = ticket;            
          request.symbol    = deal_symbol;         
          request.sl        = newSL;            
          request.tp        = orderTP;               
          request.magic     = magic; 
          int Ans = OrderSend(request,result);
         }
       }
     }
   }
 }
     
//+------------------------------------------------------------------+

void calculateAskBid()
 {
  Ask = SymbolInfoDouble (_Symbol, SYMBOL_ASK);
  Bid = SymbolInfoDouble (_Symbol, SYMBOL_BID);
 }
 
//+------------------------------------------------------------------+ 

void openBuy (double lot, double StopLoss, double TakeProfit, string comment)
 {
  double SL;
  double TP;
  if (StopLoss == 0) SL = 0;
  else SL = Ask - StopLoss * _point;
  if (TakeProfit == 0) TP = 0;
  else TP = Ask + TakeProfit * _point;

  bool Ans = false;
  
  MqlTradeRequest request = {}; 
  request.action = TRADE_ACTION_DEAL;            
  request.magic = magic;                         
  request.comment = comment;
  request.symbol = _Symbol;                      
  request.volume = lot;                         
  request.sl = SL;                              
  request.tp = TP;                               
  request.type = ORDER_TYPE_BUY;
  request.price = Ask;                 
  request.deviation = Slippage;
// Dynamically set the filling mode based on symbol's supported modes
  if ((SymbolInfoInteger (_Symbol, SYMBOL_FILLING_MODE) & SYMBOL_FILLING_FOK) != 0) request.type_filling = ORDER_FILLING_FOK;
  else if ((SymbolInfoInteger (_Symbol, SYMBOL_FILLING_MODE) & SYMBOL_FILLING_IOC) != 0) request.type_filling = ORDER_FILLING_IOC;
  else request.type_filling = ORDER_FILLING_RETURN;

  MqlTradeResult result = {0}; 

  for (int i = 0; i < 10; i++)
   {
    Ans = OrderSend (request,result);
     
    if (Ans) break;
    Sleep (500);
   }
  if (Ans) 
   {
    Print (_Symbol,": BUY order is opened. ");
   }
  else
   {
    string Err = IntegerToString (GetLastError());
    Print (_Symbol,": Error opening the BUY order: ", Err, ". Retcode: ", result.retcode);
   }
 }
 
//+------------------------------------------------------------------+

void openSell (double lot, double StopLoss, double TakeProfit, string comment)
 {
  double SL;
  double TP;
  if (StopLoss == 0) SL = 0;
  else SL = Bid + StopLoss * _point;
  if (TakeProfit == 0) TP = 0;
  else TP = Bid - TakeProfit * _point;

  bool Ans = false;

  MqlTradeRequest request = {}; 
  request.action = TRADE_ACTION_DEAL;            
  request.magic = magic;                         
  request.comment = comment;
  request.symbol = _Symbol;                      
  request.volume = lot;                          
  request.sl = SL;                               
  request.tp = TP;                                 
  request.type = ORDER_TYPE_SELL;
  request.price = Bid;                  
  request.deviation = Slippage;
// Dynamically set the filling mode based on symbol's supported modes
  if ((SymbolInfoInteger (_Symbol, SYMBOL_FILLING_MODE) & SYMBOL_FILLING_FOK) != 0) request.type_filling = ORDER_FILLING_FOK;
  else if ((SymbolInfoInteger (_Symbol, SYMBOL_FILLING_MODE) & SYMBOL_FILLING_IOC) != 0) request.type_filling = ORDER_FILLING_IOC;
  else request.type_filling = ORDER_FILLING_RETURN;

  MqlTradeResult result = {0}; 
   
  for (int i = 0; i < 10; i++)
   {
    Ans = OrderSend (request, result);
    
    if (Ans) break;
    Sleep (500);
   }
  if (Ans)
   {
    Print (_Symbol,": Sell order is opened. ");
   }
  else
   {
    string Err = IntegerToString (GetLastError());
    Print (_Symbol,": Error opening the Sell order: ", Err, ". Retcode: ", result.retcode);
   }
 }
 
//+------------------------------------------------------------------+ 
 
void closeByTime (string comment, int StopLossTime)
 {
  if (PositionsTotal() == 0) return;
  ulong ticket;
  string deal_symbol = "";
  long deal_magic = 0;
  ENUM_POSITION_TYPE deal_type;
  double volume;
  string deal_comment = "";
  MqlTradeRequest request = {};
  MqlTradeResult  result = {0};
  for (int i = PositionsTotal() - 1; i >= 0; i--)
   {
    deal_symbol = PositionGetSymbol (i);
    ticket = PositionGetInteger (POSITION_TICKET);
    deal_magic = PositionGetInteger (POSITION_MAGIC);
    deal_comment = PositionGetString (POSITION_COMMENT);
    
    if (deal_symbol == _Symbol && deal_magic == magic && deal_comment == comment)
     {
      if (int (TimeCurrent()) - PositionGetInteger (POSITION_TIME) >= StopLossTime)
       {
        volume = PositionGetDouble (POSITION_VOLUME);
        deal_type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      
        request.action       = TRADE_ACTION_DEAL; 
        request.position     = ticket;            
        request.symbol       = deal_symbol;         
        request.volume       = volume;
        request.deviation    = Slippage;
        request.magic        = deal_magic;
// Dynamically set the filling mode based on symbol's supported modes
        if ((SymbolInfoInteger (_Symbol, SYMBOL_FILLING_MODE) & SYMBOL_FILLING_FOK) != 0) request.type_filling = ORDER_FILLING_FOK;
        else if ((SymbolInfoInteger (_Symbol, SYMBOL_FILLING_MODE) & SYMBOL_FILLING_IOC) != 0) request.type_filling = ORDER_FILLING_IOC;
        else request.type_filling = ORDER_FILLING_RETURN;
      
        if (deal_type == POSITION_TYPE_BUY)
         {
          request.price = SymbolInfoDouble (deal_symbol,SYMBOL_BID);
          request.type = ORDER_TYPE_SELL;
         }
        else
         {
          if (deal_type == POSITION_TYPE_SELL)
           {
            request.price = SymbolInfoDouble (deal_symbol,SYMBOL_ASK);
            request.type = ORDER_TYPE_BUY;
           }
         }
        bool Ans = OrderSend(request,result);
        if (Ans)
         {
          Print (deal_symbol, ": Order is closed by SL Time option.");
         }
        else
         {
          Print (deal_symbol, ": Failed to close the order by SL Time option.");
         }
       }
     }  
   } 
 }

//+------------------------------------------------------------------+ 

