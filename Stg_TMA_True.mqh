/**
 * @file
 * Implements TMA_True strategy based on the TMA_True indicator.
 */

// Includes.
#include "Indi_TMA_True.mqh"

// User input params.
INPUT_GROUP("TMA True strategy: strategy params");
INPUT float TMA_True_LotSize = 0;                // Lot size
INPUT int TMA_True_SignalOpenMethod = 0;         // Signal open method
INPUT int TMA_True_SignalOpenFilterMethod = 32;  // Signal open filter method
INPUT int TMA_True_SignalOpenFilterTime = 9;     // Signal open filter time
INPUT float TMA_True_SignalOpenLevel = 0.0f;     // Signal open level
INPUT int TMA_True_SignalOpenBoostMethod = 0;    // Signal open boost method
INPUT int TMA_True_SignalCloseMethod = 0;        // Signal close method
INPUT int TMA_True_SignalCloseFilter = 32;       // Signal close filter (-127-127)
INPUT float TMA_True_SignalCloseLevel = 0.0f;    // Signal close level
INPUT int TMA_True_PriceStopMethod = 1;          // Price stop method (0-127)
INPUT float TMA_True_PriceStopLevel = 2;         // Price stop level
INPUT int TMA_True_TickFilterMethod = 28;        // Tick filter method (0-255)
INPUT float TMA_True_MaxSpread = 4.0;            // Max spread to trade (in pips)
INPUT short TMA_True_Shift = 0;                  // Shift (relative to the current bar, 0 - default)
INPUT int TMA_True_OrderCloseLoss = 0;           // Order close loss
INPUT int TMA_True_OrderCloseProfit = 0;         // Order close profit
INPUT int TMA_True_OrderCloseTime = -30;         // Order close time in mins (>0) or bars (<0)
INPUT_GROUP("TMA True: TMA True indicator params");
INPUT int TMA_True_Indi_TMA_True_Timeframe = 0;           // Timeframe
INPUT int TMA_True_Indi_TMA_True_HalfLength = 3;          // Half length
INPUT double TMA_True_Indi_TMA_True_AtrMultiplier = 1.5;  // ATR multiplier
INPUT int TMA_True_Indi_TMA_True_AtrPeriod = 6;           // ATR period
INPUT int TMA_True_Indi_TMA_True_BarsToProcess = 0;       // Bars to process
INPUT int TMA_True_Indi_TMA_True_Shift = 0;               // Indicator Shift

// Structs.

// Defines struct with default user strategy values.
struct Stg_TMA_True_Params_Defaults : StgParams {
  Stg_TMA_True_Params_Defaults()
      : StgParams(::TMA_True_SignalOpenMethod, ::TMA_True_SignalOpenFilterMethod, ::TMA_True_SignalOpenLevel,
                  ::TMA_True_SignalOpenBoostMethod, ::TMA_True_SignalCloseMethod, ::TMA_True_SignalCloseFilter,
                  ::TMA_True_SignalCloseLevel, ::TMA_True_PriceStopMethod, ::TMA_True_PriceStopLevel,
                  ::TMA_True_TickFilterMethod, ::TMA_True_MaxSpread, ::TMA_True_Shift) {
    Set(STRAT_PARAM_OCL, TMA_True_OrderCloseLoss);
    Set(STRAT_PARAM_OCP, TMA_True_OrderCloseProfit);
    Set(STRAT_PARAM_OCT, TMA_True_OrderCloseTime);
    Set(STRAT_PARAM_SOFT, TMA_True_SignalOpenFilterTime);
  }
} stg_tmat_defaults;

// Defines struct with default user indicator values.
struct Stg_TMA_True_Indi_TMA_True_Params_Defaults : Indi_TMA_True_Params {
  Stg_TMA_True_Indi_TMA_True_Params_Defaults()
      : Indi_TMA_True_Params(::TMA_True_Indi_TMA_True_Timeframe, ::TMA_True_Indi_TMA_True_HalfLength,
                             ::TMA_True_Indi_TMA_True_AtrMultiplier, ::TMA_True_Indi_TMA_True_AtrPeriod,
                             ::TMA_True_Indi_TMA_True_BarsToProcess, ::TMA_True_Indi_TMA_True_Shift) {}
} stg_tmat_indi_tmat_defaults;

#ifdef __config__
// Loads pair specific param values.
#include "config/H1.h"
#include "config/H4.h"
#include "config/H8.h"
#include "config/M1.h"
#include "config/M15.h"
#include "config/M30.h"
#include "config/M5.h"
#endif

class Stg_TMA_True : public Strategy {
 public:
  Stg_TMA_True(StgParams &_sparams, TradeParams &_tparams, ChartParams &_cparams, string _name = "")
      : Strategy(_sparams, _tparams, _cparams, _name) {}

  static Stg_TMA_True *Init(ENUM_TIMEFRAMES _tf = NULL) {
    // Initialize strategy initial values.
    Indi_TMA_True_Params _indi_params(stg_tmat_indi_tmat_defaults, _tf);
    StgParams _stg_params(stg_tmat_defaults);
#ifdef __config__
    SetParamsByTf<Indi_TMA_True_Params>(_indi_params, _tf, indi_tmat_m1, indi_tmat_m5, indi_tmat_m15, indi_tmat_m30,
                                        indi_tmat_h1, indi_tmat_h4, indi_tmat_h8);
    SetParamsByTf<StgParams>(_stg_params, _tf, stg_tmat_m1, stg_tmat_m5, stg_tmat_m15, stg_tmat_m30, stg_tmat_h1,
                             stg_tmat_h4, stg_tmat_h8);
#endif
    // Initialize indicator.
    _stg_params.SetIndicator(new Indi_TMA_True(_indi_params));
    // Initialize Strategy instance.
    ChartParams _cparams(_tf, _Symbol);
    TradeParams _tparams;
    Strategy *_strat = new Stg_TMA_True(_stg_params, _tparams, _cparams, "TMA True");
    return _strat;
  }

  /**
   * Check strategy's opening signal.
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method = 0, float _level = 0.0f, int _shift = 0) {
    Indicator *_indi = GetIndicator();
    Chart *_chart = trade.GetChart();
    bool _result = _indi.GetFlag(INDI_ENTRY_FLAG_IS_VALID, _shift);
    if (!_result) {
      // Returns false when indicator data is not valid.
      return false;
    }
    double lowest_price, highest_price;
    double _change_pc = Math::ChangeInPct(_indi[1][(int)TMA_TRUE_MAIN], _indi[0][(int)TMA_TRUE_MAIN], true);
    switch (_cmd) {
      case ORDER_TYPE_BUY:
        lowest_price = fmin3(_chart.GetLow(CURR), _chart.GetLow(PREV), _chart.GetLow(PPREV));
        _result = (lowest_price < fmax3(_indi[CURR][(int)TMA_TRUE_LOWER], _indi[PREV][(int)TMA_TRUE_LOWER],
                                        _indi[PPREV][(int)TMA_TRUE_LOWER]));
        _result &= _change_pc > _level;
        if (_method != 0) {
          if (METHOD(_method, 0)) _result &= fmin(Close[PREV], Close[PPREV]) < _indi[CURR][(int)TMA_TRUE_LOWER];
          if (METHOD(_method, 1)) _result &= (_indi[CURR][(int)TMA_TRUE_LOWER] > _indi[PPREV][(int)TMA_TRUE_LOWER]);
          if (METHOD(_method, 2)) _result &= (_indi[CURR][(int)TMA_TRUE_MAIN] > _indi[PPREV][(int)TMA_TRUE_MAIN]);
          if (METHOD(_method, 3)) _result &= (_indi[CURR][(int)TMA_TRUE_UPPER] > _indi[PPREV][(int)TMA_TRUE_UPPER]);
          if (METHOD(_method, 4)) _result &= Open[CURR] < _indi[CURR][(int)TMA_TRUE_MAIN];
          if (METHOD(_method, 5)) _result &= fmin(Close[PREV], Close[PPREV]) > _indi[CURR][(int)TMA_TRUE_MAIN];
        }
        break;
      case ORDER_TYPE_SELL:
        // Price value was higher than the upper band.
        highest_price = fmin3(_chart.GetHigh(CURR), _chart.GetHigh(PREV), _chart.GetHigh(PPREV));
        _result = (highest_price > fmin3(_indi[CURR][(int)TMA_TRUE_UPPER], _indi[PREV][(int)TMA_TRUE_UPPER],
                                         _indi[PPREV][(int)TMA_TRUE_UPPER]));
        _result &= _change_pc < -_level;
        if (_method != 0) {
          if (METHOD(_method, 0)) _result &= fmin(Close[PREV], Close[PPREV]) > _indi[CURR][(int)TMA_TRUE_UPPER];
          if (METHOD(_method, 1)) _result &= (_indi[CURR][(int)TMA_TRUE_LOWER] < _indi[PPREV][(int)TMA_TRUE_LOWER]);
          if (METHOD(_method, 2)) _result &= (_indi[CURR][(int)TMA_TRUE_MAIN] < _indi[PPREV][(int)TMA_TRUE_MAIN]);
          if (METHOD(_method, 3)) _result &= (_indi[CURR][(int)TMA_TRUE_UPPER] < _indi[PPREV][(int)TMA_TRUE_UPPER]);
          if (METHOD(_method, 4)) _result &= Open[CURR] > _indi[CURR][(int)TMA_TRUE_MAIN];
          if (METHOD(_method, 5)) _result &= fmin(Close[PREV], Close[PPREV]) < _indi[CURR][(int)TMA_TRUE_MAIN];
        }
        break;
    }
    return _result;
  }
};
