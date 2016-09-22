fs = require 'fs'

module.exports = (robot) ->
	syllables = JSON.parse fs.readFileSync 'data/syllables.json'
	custom_words = JSON.parse fs.readFileSync 'data/custom_words.json'

	starts_with = (words, count) ->
		consumed = 0
		re = /\W*\b(.+)\b\W*/
		for word in words
			# replace smart quotes/dashes with plain ones
			word = word.toUpperCase()
				.replace(/[\u2018\u2019]/g, "'")
				.replace(/[\u201C\u201D]/g, '"')
				.replace(/\u2014/g, '-')
			matches = word.match(re)
			if matches == null
				# no word characters, skip this word
				consumed += 1
				continue
			word = matches[1]
			if word of custom_words
				count -= custom_words[word]
			else if word of syllables
				count -= syllables[word]
			else
				# unknown word
				return false

			consumed += 1
			if count == 0
				return consumed
			if count < 0
				return false
		return false

	is_haiku = (message) ->
		if not message.text
			return false
		words = message.text.split ' '
		start = 0
		for line in [5, 7, 5]
			result = starts_with words[start..], line
			if result == false
				return false
			start += result
		start == words.length

	persist_custom_words = ->
		fs.writeFileSync 'data/custom_words.json', JSON.stringify custom_words

	robot.listen(
		(message) ->
			is_haiku message
		(response) ->
			response.send ":leaves: Haiku detected! :fallen_leaf:"
	)

	robot.hear /haikubot help/i, (response) ->
		response.send "Commands are: help, list, learn <word> <syllable count>, forget <word>"
		return

	robot.hear /haikubot learn (\S+) (\d+)/i, (response) ->
		count = parseInt(response.match[2])
		if count > 0
			custom_words[response.match[1].toUpperCase()] = count
			persist_custom_words()
			response.send "Thanks for teaching me!"
		return

	robot.hear /haikubot forget (\S+)/i, (response) ->
		word = response.match[1]
		if word of custom_words
			delete custom_words[word]
			persist_custom_words()
			response.send "#{word} is forgotten"
		else
			response.send "I didn't know #{word} actually"
		return

	robot.hear /haikubot list/i, (response) ->
		words = Object.keys(custom_words)
		if words.length
			response.send "I know these words:\n#{words.join('\n')}"
		else
			response.send "I don't know any custom words"
		return
