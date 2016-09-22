import codecs, json, string

lines = [line.strip() for line in codecs.open('cmudict-0.7b.txt', 'r', 'iso-8859-1') if line[0] != ';']

syllables = {}
digits = tuple(string.digits)

for line in lines:
    tokens = line.split(' ')
    count = len([token for token in tokens[1:] if token.endswith(digits)])
    syllables[tokens[0]] = count

with codecs.open('syllables.json', 'w', 'utf-8') as output:
	json.dump(syllables, output, ensure_ascii=False, indent=0, sort_keys=True)
