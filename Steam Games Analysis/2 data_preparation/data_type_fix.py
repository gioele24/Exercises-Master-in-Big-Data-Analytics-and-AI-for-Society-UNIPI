import pandas as pd
import numpy as np
from ast import literal_eval

def data_type_fix(df: pd.DataFrame, long: bool = False) -> pd.DataFrame:
    if not isinstance(df, pd.DataFrame):
        raise TypeError("Argument 'df' must be a pandas DataFrame")

    df.columns = df.columns.str.strip()

    # Convert release_date to datetime
    df['release_date'] = pd.to_datetime(df['release_date'])

    # Convert review scores to float
    df['reviews_score_fancy'] = pd.to_numeric(df['reviews_score_fancy'], errors='coerce')

    # Columns to safely evaluate from string to list/dict
    str_eval_columns = [
        'supported_languages', 'full_audio_languages', 'developers', 'publishers',
        'categories', 'genres', 'tags', 'screenshots', 'movies', 'platforms'
    ]

    for col in str_eval_columns:
        if col in df.columns:
            df[col] = df[col].apply(lambda x: safe_eval(x))

    # Handle infos_per_platform column
    if not long:
        if 'infos_per_platform' in df.columns:
            df['infos_per_platform'] = df['infos_per_platform'].apply(
                lambda x: safe_eval(x, allow_nan=True) if isinstance(x, str) else x
            )
    else:
        df['release_date_pp'] = pd.to_datetime(df['release_date_pp'])
        df['last_update_pp'] = pd.to_datetime(df['last_update_pp'])

    return df


def safe_eval(val, allow_nan=False):
    """Safely evaluate a string that represents a Python literal."""
    if not isinstance(val, str):
        return val
    try:
        return eval(val, {"nan": np.nan}) if allow_nan else literal_eval(val)
    except (ValueError, SyntaxError):
        return val
