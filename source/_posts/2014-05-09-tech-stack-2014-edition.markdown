---
layout: post
title: "Tech stack 2014 Edition"
date: 2014-05-09 09:17:02 -0500
comments: true
categories: [architecture, full-stack, infrastructure]
published: false
---
I've built a lot of things, but the most interesting thing is usually what I'm currently working on or have
built recently. With that in mind I thought I'd take a moment to reflect on the technology stack of my current
project.

<!-- more -->

# Overview
The service provided is a mobile eBook store. End users can find, buy and read books in their browser and on mobile app
platforms like iOS and Android.

# Frameworks
The framework selection was very organic and was not chosen all at once. I had extensive background in Rails so it made
sense to start there and integrate into other systems via RubyGem plugins when vanilla Rails/Database didn't fit.

## Ruby on Rails
I've been using this since version 1, and never looked back. Rails and the Ruby language "get" me. They
think the way I do – they complete me. Prior to Ruby I was using Java and writing wrappers that were very
similar Ruby and ActiveRecord/Support so to find a language and framework that did all that and more was a
dream come true.

The discovery was in 2005 which makes it 9 years old. That's like 50 tech years. That
being said. I still have not found another language or framework that does things more
intuitively that Ruby or Rails. Maybe I'm an old dog that can't learn new tricks. Maybe
I'm stuck in my ways. Regardless, I still feel productive and I believe my human clients
agree.

## Solr / Sunspot
We started using SQL search and quickly ran into performance walls for the variety queries we needed to perform, so we
needed something else. Lucene is the industry standard in searching. Solr puts a wrapper around Lucene that allows for
dynamic index fields additions and provides more search options. Sunspot integrates all that into ActiveRecord.
It took maybe 10 minutes for us to try out Sunspot in our current catalog modals and made the user search experience
faster.

The thing we miss by not having database queries is table joins. Joins are available in Solr, but have a similar
performance hit as DB. The workaround for joins was to have a wide data set.

### Example Sunspot Model Config
```ruby
class Node
  belongs_to :title
end

class Title
  has_many :nodes
  has_many :prices
  
  searchable do
    text :name
    text :contributors
    text :snippet
    
 	  integer :nodes, multiple: true do solr_nodes; end
 	  string :countries, multiple: true do solr_countries; end
 	  string :currencies, multiple: true do solr_currencies; end
  	Price.select(:country, :currency).uniq.each do |price|
  		double "#{price.country}_#{price.currency}" do solr_country_currency(price); end
  	end
  	
    # ... many other fields
    
  end
  
  def solr_countries
  	prices.pluck(:country)
  end
  
  def solr_currencies
  	prices.pluck(:currency)
  end
  
  def solr_country_currency(price)
  	prices.where(country: price.country, currency: price.currency).first.try(:price)
  end
end

class Price
  belongs_to :title
end
```

### Example Sunspot Search
```ruby
Title.search do
	full_text('cats')
	with(:US_USD).less_than(1.0)
end
```

The Sunspot site has many examples: http://sunspot.github.io/


## Redis

http://redis.io describes themselves as:

> Redis is an open source, BSD licensed, advanced key-value store.
> It is often referred to as a data structure server since keys can contain
> strings, hashes, lists, sets and sorted sets.

To me this is a remote shared hash, array, stack, and queue. All atomic all almost fast
as locale memory structures. Here's how I'm using it:

* Rails.cache for reponse caching
* Resque queues to off load long jobs to a background process.
* System wide mutex via `setnx` and `hsetnx` command
* Anything that would require a DB lock, I would prefer to let Redis handle the lock. This one concept has allowed my RDBMS to stay small and lean.
* ...

Check out their documentation for more ideas. Every time I read through the docs I come
up with 10 more things I could take off my RDBMS. If only I had could do it over again.


## Couch DB
Couch is our dump of raw contents. We only use 20% of Couch's features because the remaining map/reduce portions of the system took long for our data set. I'm sure there are better ways to use it, but in the end one the main features of how it indexes and aggregates data we can't use. Maybe in the future, but we've already moved on.

The feature we do use though is a version controlled document store. We take in various sources of data from an external source, convert it to JSON, add a few state tracking fields, and store it in Couch. Couch make the document retrieval fast and painless.

## Apache/Passenger
I should be using Nginx, but haven't quite gotten around to figuring it out. Apache is fast enough for our needs right now. Passenger is the gold standard in managing multiple Ruby web processes. Nothing too exciting here. It just works.

## Node.js
http://nodejs.org/
This is where the system starts to Frankenstein. We use Node.js for Socket.io

## Socket.io
http://socket.io/
Most of the cool factor of your system revolves around the use of Socket.io to bring realtime server push to all our front ends: Browser and Apps. When we have a flash sale or special offer web sockets delivers.


# Front End


# Infrastructure


# Back End

