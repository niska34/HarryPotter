from nrclex import NRCLex

text = "I love you too!"
text2 = "I love you and hate you too!"

emotion = NRCLex(text)

print("\n", emotion.words)
print("\n", emotion.sentences)
print("\n", emotion.affect_list)
print("\n", emotion.affect_dict)
print("\n", emotion.raw_emotion_scores)
print("\n", emotion.top_emotions)
print("\n", emotion.affect_frequencies)

emotion2 = NRCLex(text2)

print("\n", emotion2.words)
print("\n", emotion2.sentences)
print("\n", emotion2.affect_list)
print("\n", emotion2.affect_dict)
print("\n", emotion2.raw_emotion_scores)
print("\n", emotion2.top_emotions)
print("\n", emotion2.affect_frequencies)
