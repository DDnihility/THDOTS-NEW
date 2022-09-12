-----------------------
-------- Queue --------
-----------------------

Queue = {
    table = {},
    frontIndex = -1,
    backIndex = -1,
}

function Queue:Front() return self.table[self.frontIndex] end
function Queue:Back() return self.table[self.backIndex] end
function Queue:IsEmpty() return self:Size() == 0 end

function Queue:Size()
    if self.frontIndex < 0 or self.backIndex < 0 then return 0 end
    return self.frontIndex - self.backIndex + 1
end

function Queue:PushFront(val)
    self.frontIndex = self.frontIndex + 1
    self.table[self.frontIndex] = val
    if self.backIndex < 0 then self.backIndex = self.frontIndex end
end

function Queue:PopBack(val)
    if self.backIndex < 0 then return end
    self.table[self.backIndex] = nil
    self.backIndex = self.backIndex + 1

    if self:IsEmpty() then
        self.frontIndex = -1
        self.backIndex = -1
    end
end

function Queue:New()
    return DepthCloneTable(self)
end