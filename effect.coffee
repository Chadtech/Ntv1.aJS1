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

  shift: (input, effect) ->
    output = []

    if (effect.shift is 0) or (effect.shift is undefined)
      return input

    if effect.shift > 0
      input = [0].concat input
    else
      input = input.concat [0]

    shiftMagnitude = Math.abs(effect.shift)
    sampleIndex = 0
    while sampleIndex < input.length
      sample = input[sampleIndex] * (1 - shiftMagnitude) 
      sample += input[sampleIndex] * shiftMag
      output.push sample
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
    effect = effect or {}
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

    remainderAfterFade = input.length - whereEnd - 1
    while sampleIndex < remainderAfterFade
      output.push Math.round(input[sampleIndex] * finalVolume)
      sampleIndex++

    return output

  fadeIn: (input, effect) ->
    effect = effect or {}
    whereBegin = effect.beginAt or 0
    whereEnd = effect.endAt or input.length - 1
    startVolume = effect.volumeAtStart or 0
    rateOfIncrease = (1 - startVolume) / (whereEnd - whereBegin)

    output = []

    sampleIndex = 0
    while sampleIndex < whereBegin
      output.push Math.round(input[sampleIndex] * startVolume)
      sampleIndex++

    durationOfFade = whereEnd - whereBegin
    while sampleIndex < durationOfFade
      increase = ((durationOfFade - sampleIndex) * rateOfIncrease)
      output.push Math.round(input[sampleIndex] * (1 - increase))
      sampleIndex++

    remainderAfterFade = input.length - whereEnd - 1
    while sampleIndex < remainderAfterFade
      output.push input[sampleIndex]
      sampleIndex++

    return output

  rampOut: (input, effect) ->
    effect = effect or {}
    ramp = effect.rampLength or 60

    rampParameters =
      beginAt: input.length - ramp

    return @fadeOut(input, rampParameters)

  rampIn: (input, effect) ->
    effect = effect or {}
    ramp = effect.rampLength or 60

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

  factorize: (fraction) ->
    numeratorsFactors = []
    denominatorsFactors = []

    isInteger = (number) ->
      if number % 1 is 0
        return true
      else
        return false

    denominatorCandidate = 1
    while not isInteger(fraction * denominatorCandidate)
      denominatorCandidate++

    denominator = denominatorCandidate
    numerator = fraction * denominator

    factoringCandidate = 2
    while factoringCandidate <= denominator
      if isInteger(denominator / factoringCandidate)
        denominator /= factoringCandidate
        denominatorsFactors.push factoringCandidate
      else
        factoringCandidate++

    factoringCandidate = 2
    while factoringCandidate <= numerator
      if isInteger(numerator / factoringCandidate)
        numerator /= factoringCandidate
        numeratorsFactors.push factoringCandidate
      else
        factoringCandidate++

    return [numeratorsFactors, denominatorsFactors]

  speed: (input, effect) ->
    output = []
    factors = @factorize effect.factor

    multiplySpeed = (sound, factorIncrease) ->
      spedUpSound = []
      interval = 0

      while interval < (input.length // factorIncrease)
        averageValue = 0
        sampleIndex = 0
        while sampleIndex < factorIncrease
          intervalIndex = sampleIndex + (interval * factorIncrease)
          averageValue += sound[intervalIndex]
          sampleIndex++
        averageValue /= factorIncrease

        spedUpSound.push averageValue
        interval++

      if (sound.length / factorIncrease) % 1 isnt 0
        amountOfEndSamples = (sound.length // factorIncrease)
        amountOfEndSamples *= factorIncrease
        amountOfEndSamples = input.length - amountOfEndSamples
        unless amountOfEndSamples < (factorIncrease / 2)
          averageValue = 0
          sampleIndex = 0

          while sampleIndex < amountOfEndSamples
            averageValue += sound[sound.length - 1 - sampleIndex]
            sampleIndex++

          averageValue /= amountOfEndSamples
          spedUpSound.push averageValue

      return spedUpSound
 
    divideSpeed = (sound, factorDecrease) ->
      slowedDownSound = []

      sampleIndex = 0
      while sampleIndex < (sound.length - 1)
        amplitudeDifference = sound[sampleIndex + 1]
        amplitudeDifference -= sound[sampleIndex]

        differenceAcrossDistance = amplitudeDifference
        differenceAcrossDistance /= factorDecrease

        intervalIndex = 0
        while intervalIndex < factorDecrease
          sample = sound[sampleIndex]
          sample += Math.round(intervalIndex * differenceAcrossDistance)
          slowedDownSound.push sample
          intervalIndex++
        sampleIndex++

      unAverageableEndBitIndex = 1
      while unAverageableEndBitIndex < factorDecrease
        slowedDownSound.push sound[sound.length - 1]
        unAverageableEndBitIndex++

      return slowedDownSound

    decreaseIndex = 0
    while decreaseIndex < factors[1].length
      input = divideSpeed(input, factors[1][decreaseIndex])
      decreaseIndex++

    increaseIndex = 0
    while increaseIndex < factors[0].length
      input = multiplySpeed(input, factors[0][increaseIndex])
      increaseIndex++

    output = input
    return output

  grain: (input, effect) ->
    output = []
    factor = effect.factor or 1
    grainLength = effect.grainLength
    passes = effect.passes
    grainRate = grainLength / passes
    grains = []

    sampleIndex = 0
    while sampleIndex < input.length
      startingSample = sampleIndex // 1
      decimalOfSample = sampleIndex % 1
      thisGrainLength = 0
      
      if (input.length - sampleIndex) > grainLength
        thisGrainLength = grainLength
      else
        thisGrainLength = input.length - sampleIndex

      grainEnd = sampleIndex + thisGrainLength
      thisGrain = input.slice(sampleIndex, grainEnd)
      grains.push @shift(thisGrain, decimalOfSample)

      sampleIndex += grainRate

    grainIndex = 0
    while grainIndex < grains.length
      grains[grainIndex] = @speed grains[grainIndex], factor: factor
      grains[grainIndex] = @fadeIn(@fadeOut(grains[grainIndex]))
      grainIndex++

    sampleIndex = 0
    while sampleIndex < input.length
      output.push 0
      sampleIndex++

    intervalIndex = 0
    grainIndex = 0
    while grainIndex < grains.length
      sampleIndex = 0
      while sampleIndex < grains[grainIndex].length
        intervalIndex = grainIndex
        intervalIndex *= grainRate
        intervalIndex = intervalIndex // 1
        intervalIndex += sampleIndex
        output[intervalIndex] += grains[grainIndex][sampleIndex]
        sampleIndex++
      grainIndex++

    return output

  superGrain: (input, effect) ->
    effect = effect or {}
    passes = effect.passes or 3
    grainLength = effect.grainLength or 8048
    iterations = effect.iterations or 10
    factor = effect.factor or 1
    breath = effect.breath or 0.5
    renditions = []

    iteration = 0
    while iteration < iterations
      thisGrainLength = (grainLength / iterations) 
      thisGrainLength *= iteration
      thisGrainLength += grainLength * breath
      thisGrainLength = thisGrainLength // 1

      effectOfThisIteration =
        factor:      factor
        grainLength: thisGrainLength
        passes:      passes

      renditions.push @grain(input, effectOfThisIteration)
      iteration++

    output = []
    sampleIndex = 0
    while sampleIndex < input.length
      output.push 0
      sampleIndex++

    for rendition in renditions
      sampleIndex = 0
      while sampleIndex < rendition.length
        output[sampleIndex] += rendition[sampleIndex] / iterations
        sampleIndex++

    return output



  glissando: (input, effect) ->
    output = []
    factor = effect.factor or 1
    grainLength = effect.grainLength
    passes = effect.passes
    grainRate = grainLength / passes
    grains = []

    sampleIndex = 0
    while sampleIndex < input.length
      startingSample = sampleIndex // 1
      decimalOfSample = sampleIndex % 1
      thisGrainLength = 0
      
      if (input.length - sampleIndex) > grainLength
        thisGrainLength = grainLength
      else
        thisGrainLength = input.length - sampleIndex

      grainEnd = sampleIndex + thisGrainLength
      thisGrain = input.slice(sampleIndex, grainEnd)
      grains.push @shift(thisGrain, decimalOfSample)

      sampleIndex += grainRate

    factorIncrement = (factor - 1) / grains.length

    grainIndex = 0
    while grainIndex < grains.length
      thisGrainsFactor = factor: ((factorIncrement * grainIndex) + 1).toFixed(2)
      grains[grainIndex] = @speed grains[grainIndex], thisGrainsFactor
      grains[grainIndex] = @fadeIn(@fadeOut(grains[grainIndex]))
      grainIndex++

    sampleIndex = 0
    while sampleIndex < input.length
      output.push 0
      sampleIndex++

    intervalIndex = 0
    grainIndex = 0
    while grainIndex < grains.length
      sampleIndex = 0
      while sampleIndex < grains[grainIndex].length
        intervalIndex = grainIndex
        intervalIndex *= grainRate
        intervalIndex = intervalIndex // 1
        intervalIndex += sampleIndex
        output[intervalIndex] += grains[grainIndex][sampleIndex]
        sampleIndex++
      grainIndex++

    return output

















