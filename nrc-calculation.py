import pandas as pd
from nrclex import NRCLex

dialogue = pd.read_csv(
    "ProcessedMovieData - Scripts, Characters/Dialogue_allMovies.csv"
)
dim_emolex = pd.read_csv("DIM_EMOLEX - List 1.csv")


def analyze_sentiment(text):
    text_object = NRCLex(text)
    return text_object.raw_emotion_scores, text_object.affect_frequencies


dialogue_emotions = []

for index, row in dialogue.iterrows():
    dialogue_id = row["Dialogue ID"]
    text = row["Dialogue"]
    sentiment_scores, affect_frequencies = analyze_sentiment(text)

    # Continue if no emotion detected
    if not sentiment_scores:
        continue

    for emotion, score in sentiment_scores.items():
        if score > 0.0:
            frequency = affect_frequencies.get(emotion)
            if frequency is not None:  # Do not append 0 frequencies
                dialogue_emotions.append(
                    {
                        "ID_DIALOGUE": dialogue_id,
                        "EMOTION": emotion,
                        "SCORE": score,
                        "SCORE_FREQUENCY": round(frequency, 3),
                    }
                )

df_dialogue_emotions = pd.DataFrame(dialogue_emotions)
print("Prvé riadky v dialogue_emotions:")
print(df_dialogue_emotions.head())

dim_emolex_dict = dim_emolex.set_index("EMOTION")["ID_EMOLEX"].to_dict()

df_dialogue_emotions["ID_EMOLEX"] = df_dialogue_emotions["EMOTION"].map(dim_emolex_dict)

df_dialogue_emotions = df_dialogue_emotions.dropna(subset=["ID_EMOLEX"])

final_table = df_dialogue_emotions[
    ["ID_DIALOGUE", "ID_EMOLEX", "SCORE", "SCORE_FREQUENCY"]
]

final_table.to_csv("BRIDGE_DIALOGUE_EMOLEX2.csv", index=False)
