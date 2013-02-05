-- Set up the circular buffer
buffer = {}
buffer.size = 50
buffer.start = 1
buffer.ending = 1

-- Add an element to the circular buffer
function buffer:Add(entry)
  buffer[(buffer.ending % buffer.size) + 1] = entry --LUA likes indices 1-20 rather than 0-19.
  buffer.ending = (buffer.ending + 1)
  if buffer.ending > buffer.size then buffer.ending = 1 end --LUA style modulo ;)
  
  if buffer.ending == buffer.start then
  	buffer.start = buffer.start + 1
  	if buffer.start > buffer.size then buffer.start = 1 end --LUA style modulo ;)
  end
end

function buffer:Reset()
  buffer.start = 1
  buffer.ending = 1
end

-- Pretend that this is an array with the latest element being at index 1 and past elements being at increasing index (aka a stack)
function buffer:Get(index)
  return buffer[(buffer.start + index % buffer.size) + 1]
end

function buffer:Count()
	if buffer.ending > buffer.start then return buffer.ending - buffer.start
	else return buffer.size - buffer.start + buffer.ending 
	end
end

--Delicious copy pasta

timeBuffer = {}
timeBuffer.size = 50
timeBuffer.start = 1
timeBuffer.ending = 1
--setmetatable(timeBuffer, buffer) -- Didn't really seem to work, I'm probably doing it wrong.

-- Add an element to the circular buffer
function timeBuffer:Add(entry)
  timeBuffer[(timeBuffer.ending % timeBuffer.size) + 1] = entry --LUA likes indices 1-20 rather than 0-19.
  timeBuffer.ending = (timeBuffer.ending + 1)
  if timeBuffer.ending > timeBuffer.size then timeBuffer.ending = 1 end --LUA style modulo ;)
  
  if timeBuffer.ending == timeBuffer.start then
  	timeBuffer.start = timeBuffer.start + 1
  	if timeBuffer.start > timeBuffer.size then timeBuffer.start = 1 end --LUA style modulo ;)
  end
end

function timeBuffer:Reset()
  timeBuffer.start = 1
  timeBuffer.ending = 1
end

-- Pretend that this is an array with the latest element being at index 1 and past elements being at increasing index (aka a stack)
function timeBuffer:Get(index)
  return timeBuffer[(timeBuffer.start + index % timeBuffer.size) + 1]
end

function timeBuffer:Count()
	if timeBuffer.ending > timeBuffer.start then return timeBuffer.ending - timeBuffer.start
	else return timeBuffer.size - timeBuffer.start + timeBuffer.ending 
	end
end