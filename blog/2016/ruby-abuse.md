---
title: "Ruby Abuse: How Not to Write Ruby, But Still Have Fun"
date: 2016-04-30
created: 2016-04-30T00:00:00Z
type: blog
status: settled
publish: [ddrscott]
source: import
prompt: "Import from blog post: 2016/ruby-abuse.markdown"
---

# Ruby Abuse: How Not to Write Ruby, But Still Have Fun
<!-- more -->
```ruby
alias λ lambda

sadd    = λ {|ns, a|   [*ns, a].sort                }
hsort   = λ {|h|       Hash[h.sort]                 }
hadd    = λ {|h, n, g| h.merge(g => sadd.(h[g], n)) }
school  = λ {|gs|      School.new(gs)               }

School = Struct.new(:gs) do
  define_method :add,     λ {|n, g| (school . (hsort . (hadd . (to_hash, n, g)))) }
  define_method :to_hash, λ {| |    gs || {} }
  define_method :grade,   λ {|g|    to_hash[g] || [] }
end
```
