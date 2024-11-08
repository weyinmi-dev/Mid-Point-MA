//+------------------------------------------------------------------+
//|                                                  ATR_Channel.mq4 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Weyinmi"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

//
//Indicator properties
//
#property indicator_buffers 3

// Main line properties
#property indicator_label1 "Main"
#property indicator_style1 STYLE_SOLID
#property indicator_type1 DRAW_NONE

// Upper line Properties
#property indicator_color2 clrGreen
#property indicator_label2 "Up"
#property indicator_style2 STYLE_SOLID
#property indicator_type2 DRAW_LINE
#property indicator_width2 1 // 

// Lower line Properties
#property indicator_color3 clrRed
#property indicator_label3 "Down"
#property indicator_style3 STYLE_SOLID
#property indicator_type3 DRAW_LINE
#property indicator_width3 1 // 

//
// Inputs
//
//Fast Moving Average
input int                InpFastMABars         = 10;          // Fast Moving Average bars
input ENUM_MA_METHOD     InpFastMAMethod       = MODE_SMA;    // Fast Moving Average Method
input ENUM_APPLIED_PRICE InpFastMAAppliedPrice = PRICE_CLOSE; // Fast Moving average applied Price

//Slow Moving Average
input int                InpSlowMABars         = 50;          // Slow Moving Average bars
input ENUM_MA_METHOD     InpSlowMAMethod          = MODE_SMA;    // Slow Moving Average Method
input ENUM_APPLIED_PRICE InpSlowMAAppliedPrice = PRICE_CLOSE; // Slow Moving average applied Price
//
// Indicator data buffers
//
double BufferMain[];
double BufferUp[];
double BufferDown[];
//
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
      SetIndexBuffer(MODE_MAIN, BufferMain);
      SetIndexBuffer(MODE_UPPER, BufferUp);
      SetIndexBuffer(MODE_LOWER, BufferDown);
      return(INIT_SUCCEEDED);
  }
//
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
      // How many bars to calculate
      int count = rates_total - prev_calculated; // no of bars - no already calculated
      if ( prev_calculated > 0 ) count++;        // force last calculated to be done again
      
      // count down = from left to right, not essential for this
      // but for some indicators each value depends on values before
      for( int i = count - 1; i >= 0; i-- )
      {
         BufferUp[i] = EMPTY_VALUE;
         BufferDown[i] = EMPTY_VALUE;
      
         double fast = iMA(Symbol(), Period(), InpFastMABars, 0, InpFastMAMethod, InpFastMAAppliedPrice, i );
         double slow = iMA( Symbol(), Period(), InpSlowMABars, 0, InpSlowMAMethod, InpSlowMAAppliedPrice, i);
         double ma = ( fast + slow ) / 2;
         
         BufferMain[i] = ma;
         
         if( fast >= slow ) 
         {
            BufferUp[i] = BufferMain[i];
            
            if(i < (rates_total - 1) && BufferUp[i+1] == EMPTY_VALUE)
            {
               BufferDown[i] = BufferMain[i];
            }
         }
         else
         {
            BufferDown[i] = BufferMain[i];
            
            if(i < (rates_total - 1) && BufferDown[i+1] == EMPTY_VALUE)
            {
               BufferUp[i] = BufferMain[i];
            }
         }
      
      }
      return(rates_total);
  }
//+------------------------------------------------------------------+
