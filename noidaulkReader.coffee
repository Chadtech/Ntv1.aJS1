Nd = require './Nd/noidaulk'
Nt = require './Nt/noitech'

gen = Nt.generate
eff = Nt.effect

piece =
  beatLength: 22050
  scale: [1, 9/8, 5/4, 4/3, 3/2, 5/3, 15/8]
  tonic: 25
  length: 551250
  voices: []
  content: []

voice0Timbre =
  length:     11025
  amplitude:  0.5
  tone:       1.01 * 100

voice0 =
  timbre: voice0Timbre
  at: (note) ->
    expressionOfThisNote = {}
    for property in Object.keys(@timbre)
      expressionOfThisNote[property] = @timbre[property]

    for property in Object.keys(note)
      if expressionOfThisNote[property] isnt undefined
        expressionOfThisNote[property] = note[property]

    return eff.fadeOut(gen.sine expressionOfThisNote)

piece.voices.push voice0

piece.content = gen.silence length: piece.length

piece.content = Nt.mix voice0.at({tone: (32 * piece.tonic)}), piece.content, 0

Nt.buildFile 'piece.wav', [piece.content]