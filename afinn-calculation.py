import pandas as pd
from afinn import Afinn

dialogues = pd.read_csv("/data/in/tables/DIALOGUE.csv")
fact_dialogue = pd.read_csv("/data/in/tables/FACT_DIALOGUE.csv")

# Afinn sentiment analyzer
afinn = Afinn()

dialogues["SENTIMENT_AFINN"] = dialogues["Dialogue"].apply(afinn.score)

sentiment_map = dict(zip(dialogues["Dialogue_ID"], dialogues["SENTIMENT_AFINN"]))

fact_dialogue["SENTIMENT_AFINN"] = fact_dialogue["ID_DIALOGUE"].map(sentiment_map)

fact_dialogue.to_csv("/data/out/tables/FACT_TABLE_AFINN_DENI.csv", index=False)
