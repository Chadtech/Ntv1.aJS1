Nu = require './Ndu/noidaulkUtility'
fs = require 'fs'

module.exports =
  loadScore: (scoreFileName) ->
    scoreAsString = fs.readFileSync(scoreFileName, 'utf8')
    scoreAsArrays = Nu.stringToRows scoreAsString

    score = {}
    for voice in scoreAsArrays
      score[voice[0]] = []
      noteIndex = 1
      while noteIndex < voice.length
        score[voice[0]].push voice[noteIndex]
        noteIndex++

    return score

  loadPieceProperties: (piecePropertiesFileName) ->
    pieceProperties =
      beatLength: 0
      barLength:  24
      length:     12039300 # 4 minutes and 33 seconds
      voices:     []
      scale:      []
      tonic:      25

    piecePropertiesAsString = 
      fs.readFileSync(piecePropertiesFileName, 'utf8')
    propsCSV = Nu.stringToRows piecePropertiesAsString

    for row in propsCSV
      if pieceProperties[row[0]] isnt undefined
        switch typeof pieceProperties[row[0]]
          when 'number'
            pieceProperties[row[0]] = row[1]
          when 'object'
            if pieceProperties[row[0]] instanceof Array
              cellIndex = 1
              while cellIndex < row.length
                pieceProperties[row[0]].push row[cellIndex]
                cellIndex++

    return pieceProperties

  loadTime: (timeFileName) ->
    timeAsString = fs.readFileSync(timeFileName, 'utf8')
    time = Nu.stringToRows timeAsString

    return time

  getProject: (projectName) ->
    project = 
      score:      @loadScore projectName + ' - score.csv', 'utf8'
      time:       @loadTime projectName + ' - time.csv', 'utf8'
      properties: @loadPieceProperties projectName + ' - properties.csv', 'utf8'

    return project





