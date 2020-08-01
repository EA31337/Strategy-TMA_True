/**
 * @file
 * Implements Demo strategy based on the Demo indicator.
 */

// User input params.
INPUT float Demo_LotSize = 0;               // Lot size
INPUT int Demo_Shift = 0;                   // Shift (relative to the current bar, 0 - default)
INPUT int Demo_SignalOpenMethod = 0;        // Signal open method
INPUT int Demo_SignalOpenFilterMethod = 0;  // Signal open filter method
INPUT float Demo_SignalOpenLevel = 0;       // Signal open level
INPUT int Demo_SignalOpenBoostMethod = 0;   // Signal open boost method
INPUT int Demo_SignalCloseMethod = 0;       // Signal close method
INPUT float Demo_SignalCloseLevel = 0;      // Signal close level
INPUT int Demo_PriceLimitMethod = 0;        // Price limit method
INPUT float Demo_PriceLimitLevel = 2;       // Price limit level
INPUT int Demo_TickFilterMethod = 1;        // Tick filter method (0-255)
INPUT float Demo_MaxSpread = 2.0;           // Max spread to trade (in pips)

// Includes.
#include <EA31337-classes/Indicators/Indi_Demo.mqh>
#include <EA31337-classes/Strategy.mqh>

// Defines struct with default user strategy values.
struct Stg_Demo_Params_Defaults : StgParams {
  Stg_Demo_Params_Defaults()
      : StgParams(::Demo_SignalOpenMethod, ::Demo_SignalOpenFilterMethod, ::Demo_SignalOpenLevel,
                  ::Demo_SignalOpenBoostMethod, ::Demo_SignalCloseMethod, ::Demo_SignalCloseLevel,
                  ::Demo_PriceLimitMethod, ::Demo_PriceLimitLevel, ::Demo_TickFilterMethod, ::Demo_MaxSpread,
                  ::Demo_Shift) {}
} stg_demo_defaults;

// Defines struct to store indicator and strategy params.
struct Stg_Demo_Params {
  StgParams sparams;

  // Struct constructors.
  Stg_Demo_Params(StgParams &_sparams) : sparams(stg_demo_defaults) { sparams = _sparams; }
};

// Loads pair specific param values.
#include "sets/EURUSD_H1.h"
#include "sets/EURUSD_H4.h"
#include "sets/EURUSD_H8.h"
#include "sets/EURUSD_M1.h"
#include "sets/EURUSD_M15.h"
#include "sets/EURUSD_M30.h"
#include "sets/EURUSD_M5.h"

class Stg_Demo : public Strategy {
 public:
  Stg_Demo(StgParams &_params, string _name) : Strategy(_params, _name) {}

  static Stg_Demo *Init(ENUM_TIMEFRAMES _tf = NULL, long _magic_no = NULL, ENUM_LOG_LEVEL _log_level = V_INFO) {
    // Initialize strategy initial values.
    StgParams _stg_params(stg_demo_defaults);
    if (!Terminal::IsOptimization()) {
      SetParamsByTf<StgParams>(_stg_params, _tf, stg_demo_m1, stg_demo_m5, stg_demo_m15, stg_demo_m30, stg_demo_h1,
                               stg_demo_h4, stg_demo_h8);
    }
    // Initialize indicator.
    _stg_params.SetIndicator(new Indi_Demo());
    // Initialize strategy parameters.
    _stg_params.GetLog().SetLevel(_log_level);
    _stg_params.SetMagicNo(_magic_no);
    _stg_params.SetTf(_tf, _Symbol);
    // Initialize strategy instance.
    Strategy *_strat = new Stg_Demo(_stg_params, "Demo");
    _stg_params.SetStops(_strat, _strat);
    return _strat;
  }

  /**
   * Check strategy's opening signal.
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method = 0, float _level = 0.0f) {
    Indicator *_indi = Data();
    bool _is_valid = _indi[CURR].IsValid();
    bool _result = _is_valid;
    if (!_result) {
      // Returns false when indicator data is not valid.
      return false;
    }
    double _value = _indi[CURR][0];
    switch (_cmd) {
      case ORDER_TYPE_BUY:
        // Buy signal.
        _result = _indi[CURR][0] < _indi[PREV][0];
        break;
      case ORDER_TYPE_SELL:
        // Sell signal.
        _result = _indi[CURR][0] < _indi[PREV][0];
        break;
    }
    return _result;
  }

  /**
   * Gets price limit value for profit take or stop loss.
   */
  float PriceLimit(ENUM_ORDER_TYPE _cmd, ENUM_ORDER_TYPE_VALUE _mode, int _method = 0, float _level = 0.0f) {
    // Indicator *_indi = Data();
    double _trail = _level * Market().GetPipSize();
    // int _bar_count = (int)_level * 10;
    int _direction = Order::OrderDirection(_cmd, _mode);
    double _default_value = Market().GetCloseOffer(_cmd) + _trail * _method * _direction;
    double _result = _default_value;
    // ENUM_APPLIED_PRICE _ap = _direction > 0 ? PRICE_HIGH : PRICE_LOW;
    switch (_method) {
      case 1:
        // Trailing stop here.
        break;
    }
    return (float)_result;
  }
};
