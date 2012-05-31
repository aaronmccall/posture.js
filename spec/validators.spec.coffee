Posture = require("../lib/posture")
should = require("should")

describe "Validators", ->
  it "value not less than lessThan param should throw NotLessThan", (done) ->
    try
      Posture.Validators.lessThan(5, 3)
    catch err
      err.should.be.an.instanceOf(Posture.Validators.NotLessThan)
    done()

  it "value not greater than greaterThan param should throw NotGreaterThan"

  it "empty value should throw IsEmpty"

  it "number with too many decimal places should throw Invalid"

  it "value not matching regex pattern should throw Invalid"