Nt = require './../Nt/noitech'
Nd = require './../Nd/Noidaulk'
fs = require 'fs'

zeroPadder = (number, numberOfZerosToFill) ->
  numberAsString = number + ''
  while numberAsString.length < numberOfZerosToFill
    numberAsString = '0' + numberAsString
  return numberAsString

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

    for voice in voices
      for note in score[voice.name]
        if note['tone'] isnt undefined
          note['tone'] = @noteToFrequency(note['tone'], piece)

    for voice in voices
      noteIndex = 0
      while noteIndex < score[voice.name].length
        if score[voice.name][noteIndex]['tone'] isnt undefined
          thisSound = voice.generate score[voice.name][noteIndex]
          performance = Nt.mix thisSound, performance, time[noteIndex]
        noteIndex++

    return performance

  identical: (object0, object1, dimensions) ->
    identical = true
    object0sKeys = Object.keys(object0)
    object1sKeys = Object.keys(object1)

    for dimension in dimensions
      existsInObject0 = object0[dimension] isnt undefined
      existsInObject1 = object1[dimension] isnt undefined
      if existsInObject1 and existsInObject0
        if not (object0[dimension] is object1[dimension])
          identical = false
      else
        identical = false

    return false

  generateBits: (piece, voices, next) ->
    performance = piece.performance
    score = piece.score
    time = piece.time.dist

    for voice in voices
      for note in score[voice.name]
        if note['tone'] isnt undefined
          note['tone'] = @noteToFrequency(note['tone'], piece)

    for voice in voices
      noteIndex = 0
      while noteIndex < score[voice.name].length
        if score[voice.name][noteIndex]['tone'] isnt undefined
          thisSound = voice.generate score[voice.name][noteIndex]
          fileName = 'bits/'
          fileName += voice.name
          fileName += zeroPadder(noteIndex, 10)
          fileName += '.wav'
          Nt.buildFile fileName, [thisSound]
        noteIndex++

    next(piece, voices)

  assembleBits: (piece, voices) ->
    performance = piece.performance
    score = piece.score
    time = piece.time.dist

    for voice in voices
      for note in score[voice.name]
        if note['tone'] isnt undefined
          note['tone'] = @noteToFrequency(note['tone'], piece)

    for voice in voices
      noteIndex = 0
      while noteIndex < score[voice.name].length
        if score[voice.name][noteIndex]['tone'] isnt undefined
          fileName =  'bits/'
          fileName += voice.name
          fileName += zeroPadder(noteIndex, 10)
          fileName += '.wav'
          thisSound = Nt.open(fileName)
          thisSound = thisSound[0]
          performance = Nt.mix thisSound, performance, time[noteIndex]
        noteIndex++

    Nt.buildFile 'piece.wav', [performance]

  init: (projectName) ->
    fs.mkdir 'oldsh', (msg) ->
      console.log msg
    fs.mkdir 'newsh', (msg) ->
      console.log msg
    fs.mkdir 'bits', (msg) ->
      console.log msg

    piece = Nd.getPiece(projectName)
    dimensions = piece.props['dimensions']

    fs.createReadStream(projectName + ' - properties.csv')
      .pipe(fs.createWriteStream('newsh/' + projectName + ' - properties.csv'))

    fs.createReadStream(projectName + ' - time.csv')
      .pipe(fs.createWriteStream('newsh/' + projectName + ' - time.csv'))

    for dimension in dimensions
      fs.createReadStream(projectName + ' - ' + dimension + '.csv')
        .pipe(fs.createWriteStream('newsh/' + projectName + ' - ' + dimension + '.csv'))      




