Ndu = require './Ndu/noidaulkUtility'
Nt = require './../Nt/noitech'
gen = Nt.generate
fs = require 'fs'

module.exports =
  loadScoreDimension: (scoreName, dimensionName) ->
    fileName = scoreName + ' - ' + dimensionName + '.csv'
    scoreAsString = fs.readFileSync(fileName, 'utf8')
    scoreAsArrays = Ndu.stringToRows scoreAsString
    scoreAsArrays = Ndu.cleanRows scoreAsArrays

    dimension = {}
    for voice in scoreAsArrays
      dimension[voice[0]] = []
      noteIndex = 1
      while noteIndex < voice.length
        if not isNaN(parseFloat(voice[noteIndex]))
          dimension[voice[0]].push parseFloat(voice[noteIndex])
        else
          dimension[voice[0]].push voice[noteIndex]
        noteIndex++

    return dimension

  loadTime: (projectName) ->
    fileName = projectName + ' - time.csv'
    timeAsString = fs.readFileSync(fileName, 'utf8')
    timeAsArrays = Ndu.stringToRows timeAsString
    timeAsArrays = Ndu.cleanRows timeAsArrays

    time = {}
    for row in timeAsArrays
      time[row[0]] = []
      cellIndex = 1
      while cellIndex < row.length
        if row[cellIndex] isnt ''
          time[row[0]].push parseFloat(row[cellIndex])
        else
          time[row[0]].push row[cellIndex]
        cellIndex++

    project = @loadProperties(projectName)

    time['dist'] = []
    summationOfTime = 0
    velocityIndex = 0
    while velocityIndex < time['vel'].length
      time['dist'].push summationOfTime
      summationOfTime += time['vel'][velocityIndex] * project['beat length']
      velocityIndex++

    time['duration'] = summationOfTime

    return time

  loadProperties: (projectName) ->
    pieceArrayContentTypes =
      'scale': 'numbers'
      'dimensions': 'words'
      'voices': 'words'

    pieceProperties = 
      'beat length': 22050
      'scale': []
      'tonic': 25
      'length': 0
      'dimensions': []
      'voices': []

    fileName = projectName + ' - properties.csv'
    project = fs.readFileSync(fileName, 'utf8')

    project = Ndu.stringToRows project
    project = Ndu.cleanRows project

    for row in project
      if pieceProperties[row[0]] isnt undefined
        switch typeof pieceProperties[row[0]]
          when 'number'
            pieceProperties[row[0]] = parseInt(row[1])
          when 'object'
            if pieceProperties[row[0]] instanceof Array
              cellIndex = 1
              while cellIndex < row.length
                switch pieceArrayContentTypes[row[0]]
                  when 'numbers'
                    if row[cellIndex] isnt ''
                      pieceProperties[row[0]].push parseFloat(row[cellIndex])
                  when 'words'
                    if row[cellIndex] isnt ''
                      pieceProperties[row[0]].push row[cellIndex]
                cellIndex++
      else
        pieceProperties[row[0]] = row[1]

    return pieceProperties

  getScore: (projectName) ->
    project = @loadProperties(projectName)

    score = {}
    for voice in project['voices']
      score[voice] = []
      beatIndex = 0
      while beatIndex < project['length']
        thisVoice = score[voice]
        thisVoice.push {}
        beatIndex++

    for dimension in project['dimensions']
      if dimension isnt ''
        thisDimension = @loadScoreDimension projectName, dimension
        for voice in project.voices
          cellIndex = 0
          while cellIndex < thisDimension[voice].length
            if thisDimension[voice][cellIndex] isnt ''
              # For this voice, at this time, the value
              # of this dimension, of the voice's expression
              score[voice][cellIndex][dimension] = thisDimension[voice][cellIndex]
            cellIndex++

    return score

  getPiece: (projectName) ->
    piece =
      props: @loadProperties projectName
      score: @getScore projectName
      time: @loadTime projectName

    time = piece.time

    piece.performance = gen.silence length: time.duration

    return piece