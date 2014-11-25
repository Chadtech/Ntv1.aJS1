Nd = require './Nd/noidaulk'
Nt = require './Nt/noitech'
Nr = require './noideread'

gen = Nt.generate
eff = Nt.effect

piece = Nd.getPiece 'tentones'
score = piece.score
voices = piece.props.voices
time = piece.time
scale = piece.props.scale

piece.performance = gen.silence length: time.duration
performance = piece.peformance
#console.log piece.performance

voiceCalculators =

  voice0:
    name: 'voice0'

    defaultValues:
      amplitude: 0.5
      length: 22050
      tone: 404

    generate: (note) ->
      expression = @defaultValues

      if note isnt undefined
        for key in Object.keys(note)
          if note[key] isnt undefined
            expression[key] = note[key]

      output = gen.sine expression
      output = eff.ramp output
      output = eff.fadeOut output

      return output

  voice1:
    name: 'voice1'

    defaultValues:
      amplitude: 0.5
      length: 22050
      tone: 404

    generate: (note) ->
      expression = @defaultValues

      if note isnt undefined
        for key in Object.keys(note)
          if note[key] isnt undefined
            expression[key] = note[key]

      output = gen.saw expression
      output = eff.ramp output
      output = eff.fadeOut output

      return output

voices = voices.map (voice) ->
  voice = voiceCalculators[voice]



#score['voice0'][0]['tone'] = Nr.noteToFrequency score['voice0'][0]['tone'], piece

#voice0AtNote0 = voices['voice0'].generate(score['voice0'][0])
#Nt.buildFile 'v0@n0.wav', [voice0AtNote0]

#console.log Nr.sortPiece(piece, voices)

Nt.buildFile 'FIRSTEST.wav', [Nr.sortPiece(piece, voices)]








