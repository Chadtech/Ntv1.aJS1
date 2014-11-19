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

  cutUpEveryGrain: (input, threshold) ->
    grains = []
    beginning = 0
    ending = 0
    sampleIndex = 0

    while sampleIndex < input.length
      if input[sampleIndex] < threshold
        ending = sampleIndex
        grains.push input.slice(beginning, ending)
        beginning = sampleIndex
      sampleIndex++

    return grains

  reverb: (input, effect) ->
    decay0 = 0.5 or effect.decay0
    decay1 = 0.5 or effect.decay1

    delays0 = [
      1115
      1188
      1356
      1277
      1422
      1491
      1617
      1557
    ] or effect.delays0

    delays1 = [
      255
      556
      441
      341
    ] or effect.delays1

    reverbBackPass = (subRay, decay, delays) ->
      arrayOfDelayeds = []
      delay = 0

      while delay < delays.length
        arrayOfDelayeds.push []
        padding = 0

        while padding < delays[delay]
          arrayOfDelayeds[arrayOfDelayeds.length - 1].push 0
          padding++
        sample = 0

        while sample < subRay.length
          arrayOfDelayeds[arrayOfDelayeds.length - 1].push subRay[sample]
          sample++
        sample = 0

        while sample < subRay.length
          arrayOfDelayeds[arrayOfDelayeds.length - 1][sample] += arrayOfDelayeds[arrayOfDelayeds.length - 1][sample + delays[delay]] * decay
          sample++
        delay++
      backOutRay = []
      time = 0

      while time < (Math.max.apply(null, delays) + subRay.length)
        backOutRay.push 0
        time++
      delayedArray = 0

      while delayedArray < arrayOfDelayeds.length
        sample = 0

        while sample < arrayOfDelayeds[delayedArray].length
          backOutRay[sample] += arrayOfDelayeds[delayedArray][sample] / arrayOfDelayeds.length
          sample++
        delayedArray++
      backOutRay

    reverbForwardPass = (subRay, decay, undelays) ->
      arrayOfUndelayeds = []
      undelay = 0

      while undelay < undelays.length
        arrayOfUndelayeds.push []
        time = 0

        while time < (undelays[undelay] + subRay.length)
          arrayOfUndelayeds[arrayOfUndelayeds.length - 1].push 0
          time++
        sample = 0

        while sample < subRay.length
          arrayOfUndelayeds[arrayOfUndelayeds.length - 1][sample + undelays[undelay]] += subRay[sample] * decay
          sample++
        undelay++
      forwardOutRay = []
      time = 0

      while time < (Math.max.apply(null, undelays) + subRay.length)
        forwardOutRay.push 0
        time++
      undelayedArray = 0

      while undelayedArray < arrayOfUndelayeds.length
        sample = 0

        while sample < arrayOfUndelayeds[undelayedArray].length
          forwardOutRay[sample] += arrayOfUndelayeds[undelayedArray][sample] / undelays.length
          sample++
        undelayedArray++
      forwardOutRay

    backPass = reverbBackPass(input, decay0, delays0)
    return reverbForwardPass(backPass, decayON, delaysON)

  convole: (input, effect) ->
    factor = effect.factor or 0.05
    seed = effect.seed
    output = []

    time = 0
    while time < (input.length + seed.length)
      output.push 0
      time++

    sampleIndex = 0
    while sampleIndex < input.length
      convolveIndex = 0
      while convolveIndex < seed.length
        sample = input[sampleIndex] * seed[convolveIndex]
        sample /= 32767
        sample *= factor 
        output[sampleIndex + convolveIndex] += sample
        convolveIndex++
      sampleIndex++

    return output

