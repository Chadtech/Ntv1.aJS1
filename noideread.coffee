Nt = require './Nt/noitech'

module.exports = 

  noteToFrequency: (note, piece) ->
    scale = piece.props.scale
    tonic = piece.props.tonic

    if note isnt undefined
      noteInScale = note % 10
      octave = (note // 10)

      note = scale[noteInScale] * (2 ** octave) * tonic
      note = note.toFixed(3)
      note = parseFloat(note)
      return note

  sortPiece: (piece, voices) ->
    performance = piece.performance
    score = piece.score
    time = piece.time.dist

    beatLength = piece.props['beat length']
    for voice in voices
      for note in score[voice.name]
        if note['tone'] isnt undefined
          note['tone'] = @noteToFrequency(note['tone'], piece)

    for voice in voices
      noteIndex = 0
      while noteIndex < score[voice.name].length
        if score[voice.name][noteIndex]['tone'] isnt undefined
          #console.log score[voice.name][noteIndex]
          thisSound = voice.generate score[voice.name][noteIndex]
          #console.log time[noteIndex]
          performance = Nt.mix thisSound, performance, time[noteIndex]
        noteIndex++

    return performance


