module.exports = 
  stringToRows: (string) ->
    rows = []
    thisRow = []
    cell = ''

    for character in string
      switch character
        when '\n'
          thisRow.push cell
          cell = ''
          rows.push thisRow
          thisRow = []
        when ','
          thisRow.push cell
          cell = ''
        else
          cell += character
          
    thisRow.push cell
    rows.push thisRow

    return rows

  rowsToColumns: (rows) ->
    columns = []

    for column in rows[0]
      columns.push []

    for row in rows
      cellIndex = 0
      while cellIndex < row.length
        columns[cellIndex].push row[cellIndex]
        cellIndex++

    return columns

  cleanRows: (rows) ->
    outputRows = []
    for row in rows
      if row[0] isnt 'EXCL'
        outputRows.push row

    return outputRows