module.exports =
  # invert the amplitude at each sample
  # IE
  # For each sample, and each sample is a number, 
  # multiply that number by negative one
  invert: (input) ->
    output = []

    sampleIndex = 0
    while sampleIndex < input.length
      output.push input[sampleIndex] * -1
      sampleIndex++

    return output

  padBefore: (input, effect) ->
    paddingAmount = effect.paddingAmount or 30
    output = []
    
    padding = 0
    while padding < paddingAmount
      output.push 0
      padding++

    output = output.concat input
    return output

  paddAfter: (input, effect) ->
    paddingAmount = effect.paddingAmount or 30
    output = []

    padding = 0
    while padding < paddingAmount
      output.push 0
      padding++

    output = input.concat output
    return output

  ###
  crush: (input, effect) ->
    output = []

    sampleIndex = 0
    while sampleIndex < input.length
      output.push 0
      sampleIndex++
    sampleIndex = 0
    while sampleIndex < input.length
      factor = Math.abs(input[sampleIndex] / 32767)
      output[sampleIndex] = input[sampleIndex] * factor
      sampleIndex++

    return output
    ###

  delay: (input, effect) ->
    output = []
    console.log '9', input.length
    sampleIndex = 0
    finalLength = input.length
    finalLength += (effect.numberOf * effect.distance)
    while sampleIndex < finalLength
      output.push 0
      sampleIndex++

    console.log 'A', output.length
    sampleIndex = 0
    while sampleIndex < input.length
      delayIndex = 0
      while delayIndex < effect.numberOf
        inputIndex = sampleIndex + (delayIndex * effect.distance)
        decay = effect.decayRate * delayIndex
        output[sampleIndex] += input[inputIndex] * decay
        delayIndex++
      sampleIndex++

    return output

  # 1024 is a pretty good effect.factor
  bitCrush: (input, effect) ->
    output = []

    sampleIndex = 0
    while sampleIndex < input.length
      crushed = ( input[sampleIndex] // effect.factor) * effect.factor
      output.push crushed
      sampleIndex++

    return output

  clip: (input, effect) ->
    threshold = 32767 * effect.threshold or 32767
    threshold = threshold // 1
    output = []

    sampleIndex = 0
    while sampleIndex < input.length
      if input[sampleIndex] > threshold or (-1 * threshold) > input[sampleIndex] 
        signPreserve = input[sampleIndex] / Math.abs(input[sampleIndex])
        output.push threshold * signPreserve
      else 
        output.push input[sampleIndex]
      sampleIndex++

    return output

  vol: (input, effect) ->
    output = []

    for sample in input
      output.push sample * effect.factor

    return output

  fadeOut: (input, effect) ->
    whereBegin = effect.beginAt or 0
    whereEnd = effect.endAt or (input.length - 1)
    finalVolume = effect.volumeAtEnd or 0
    rateOfReduction = (1 - finalVolume) / (whereEnd - whereBegin)

    output = []

    sampleIndex = 0
    while sampleIndex < whereBegin
      output.push input[sampleIndex]
      sampleIndex++

    durationOfFade = whereEnd - whereBegin
    while sampleIndex < durationOfFade
      fadedSample = input[sampleIndex] * (1 - (sampleIndex * rateOfReduction))
      output.push Math.round(fadedSample)
      sampleIndex++

    remainderAfterFade = input.length - whereEnd -1
    while sampleIndex < remainderAfterFade
      output.push Math.round(input[sampleIndex] * finalVolume)
      sampleIndex++

    return output

  fadeIn: (input, effect) ->
    whereBegin = effect.beginAt or 0
    whereEnd = effect.endAt or 0
    startVolume = effect.volumeAtStart or 0
    rateOfIncrease = (1 - startVolume) / (whereEnd - whereBegin)

    output = []

    sampleIndex = 0
    while sampleIndex < whereBegin
      output.push Math.round(input[sampleIndex] * startVolume)
      sampleIndex++

    durationOfFade = whereEnd - whereBegin
    while sampleIndex < durationOfFade
      increase = 1 - ((durationOfFade - sampleIndex) * rateOfIncrease)
      output.push Math.round(input[sampleIndex] * (1 - increase))
      sampleIndex++

    remainderAfterFade = input.length - whereEnd - 1
    while sampleIndex < remainderAfterFade
      output.push input[sampleIndex]
      sampleIndex++

    return output

  rampOut: (input, effect) ->
    ramp = effect.rampLength or 30

    rampParameters =
      beginAt: input.length - rampLength

    return @fadeOut(input, rampParameters)

  rampIn: (input, effect) ->
    ramp = effect.rampLength or 30

    rampParameters =
      endAt: ramp

    return @fadeIn(input, rampParameters)

  ramp: (input, effect) ->
    return @rampIn(@rampOut(input, effect), effect)

  reverse: (input) ->
    return input.reverse()

  




