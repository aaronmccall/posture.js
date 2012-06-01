Posture = require("../lib/posture")
should = require("should")
f = Posture.Filters

describe "Filters", ->
  it "integer should return integer version of numeric arg or NaN", (done) ->
    f.integer('1.0').should.equal(1)
    isNaN(f.integer('a1')).should.be.true
    f.integer('a1', true).should.equal(1)
    done()

  it "decimal should return float version of numeric arg or NaN", (done) ->
    f.decimal('1.0').should.equal(1.0)
    isNaN(f.decimal('a1')).should.be.true
    f.decimal('a1', true).should.equal(1.0)
    done()

  it "alpha should return only letters or letters + whitespace", (done) ->
    f.alpha('1.0').should.equal('')
    f.alpha('a1').should.equal('a')
    f.alpha('a1 ', true).should.equal('a ')
    done()

  it "alnum should return only letters and numbers", (done) ->
    f.alnum('1.0').should.equal('10')
    f.alnum('a1 ').should.equal('a1')
    f.alnum('a!1 ', true).should.equal('a1 ')
    done()

  it "to_json should return the JSON representation of the value", (done) ->
    f.to_json('1.0').should.equal('"1.0"')
    f.to_json(['a1 ']).should.equal('["a1 "]')
    f.to_json({foo: 'bar'}).should.equal('{"foo":"bar"}')
    done()

  it "trim should remove leading and trailing whitespace", (done) ->
    f.trim('1.0').should.equal('1.0')
    f.trim('  a1  ').should.equal('a1')
    f.trim('a1 ').should.equal('a1')
    f.trim(' a1').should.equal('a1')
    done()

  it "regex should replace pattern by replacement", (done) ->
    f.regex('crayola', /ola/, 'fish').should.equal('crayfish')
    f.regex('crayola', /^cray/, 'rock').should.equal('rockola')
    f.regex('crayola', /(cray)([aeiou])(la)/, (matched, captures...) ->
      [offset, str] = captures.splice(-2)
      captures.length.should.equal(3)
      [first, middle, last] = captures
      return matched.replace(first, 'snap').replace(last, 'rama')
    ).should.equal('snaporama')
    done()

  it "bool should convert value to boolean", (done) ->
    f.bool({}).should.equal(false)
    f.bool([]).should.equal(false)
    f.bool('no', true).should.equal(false)
    f.bool('off').should.equal(true)
    f.bool('null', true).should.equal(false)
    f.bool('0').should.equal(true)
    f.bool(0).should.equal(false)
    f.bool('a1').should.equal(true)
    f.bool(1).should.equal(true)
    done()