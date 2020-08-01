/*
 * @file
 * Defines strategy's default parameter values
 * for the given pair symbol and timeframe.
 */

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_TMA_True_Params_M5 : StgParams {
  // Struct constructor.
  Stg_TMA_True_Params_M5() : StgParams(stg_tmat_defaults) {
    lot_size = 0;
    signal_open_method = 0;
    signal_open_filter = 1;
    signal_open_level = 0;
    signal_open_boost = 0;
    signal_close_method = 0;
    signal_close_level = 0;
    price_limit_method = 0;
    price_limit_level = 2;
    tick_filter_method = 1;
    max_spread = 0;
  }
} stg_tmat_m5;
