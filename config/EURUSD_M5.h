/**
 * @file
 * Defines default strategy parameter values for the given timeframe.
 */

// Defines indicator's parameter values for the given pair symbol and timeframe.
struct Indi_TMA_True_Params_M5 : Indi_TMA_True_Params {
  Indi_TMA_True_Params_M5() : Indi_TMA_True_Params(indi_tmat_defaults, PERIOD_M5) {
    atr_multiplier = 3.0;
    atr_period = 14;
    atr_tf = 0.0;
    bars_to_process = 4.0;
    half_length = 2.0;
    shift = 0;
  }
} indi_tmat_m5;

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_TMA_True_Params_M5 : StgParams {
  // Struct constructor.
  Stg_TMA_True_Params_M5() : StgParams(stg_tmat_defaults) {
    lot_size = 0;
    signal_open_method = 2;
    signal_open_filter = 32;
    signal_open_level = (float)0.0;
    signal_open_boost = 0;
    signal_close_method = 2;
    signal_close_level = (float)0;
    price_profit_method = 60;
    price_profit_level = (float)6;
    price_stop_method = 60;
    price_stop_level = (float)6;
    tick_filter_method = 1;
    max_spread = 0;
  }
} stg_tmat_m5;
