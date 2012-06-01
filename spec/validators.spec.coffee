Posture = require("../lib/posture")
should = require("should")
v = Posture.Validators
describe "Validators", ->
  describe "lessThan", ->
    it "value not less than lessThan param should throw NotLessThan", (done) ->
      try
        v.lessThan(5, 3)
      catch err
        err.should.be.an.instanceOf(v.NotLessThan)
      done()

    it "value equal should throw NotLessThan if not allow_equal", (done) ->
      try
        v.lessThan(5, 5)
      catch err
        err.should.be.an.instanceOf(v.NotLessThan)
      done()

    it "value less than or equal when allow_equal should return true", (done) ->
      v.lessThan(4, 5).should.be.true
      v.lessThan(5, 5, true).should.be.true
      done()
  describe "greaterThan", ->
    it "value not greater than greaterThan param should throw NotGreaterThan", (done) ->
      try
        v.greaterThan(5, 7)
      catch err
        err.should.be.an.instanceOf(v.NotGreaterThan)
      done()

    it "value equal should throw NotGreaterThan when not allow_equal", (done) ->
      try
        v.greaterThan(5, 5)
      catch err
        err.should.be.an.instanceOf(v.NotGreaterThan)
      done()

    it "value greater than or equal when allow_equal should return true", (done) ->
      v.greaterThan(4, 3).should.be.true
      v.greaterThan(5, 5, true).should.be.true
      done()
  describe "notEmpty", ->
    it "empty value should throw IsEmpty", (done) ->
      try
        v.notEmpty([])
      catch err
        err.should.be.an.instanceOf(v.IsEmpty)
      try
        v.notEmpty('')
      catch err
        err.should.be.an.instanceOf(v.IsEmpty)
      done()

    it "not empty value should return true", (done) ->
      v.notEmpty(1).should.be.true
      done()

  it "number with too many decimal places should throw Invalid"

  it "value not matching regex pattern should throw Invalid"