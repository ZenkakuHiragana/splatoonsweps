
-- Fix Angle:Normalize() in SLVBase
-- The problem is functions between default Angle:Normalize() and SLVBase's have different behaviour:
-- default one changes the given angle, SLV's returns normalized angle.
-- So I need to branch the normalize function.  That's why I hate SLVBase.
if SLVBase and not SLVBase.IsFixedNormalizeAngle then
    local meta = FindMetaTable "Angle"
    local NormalizeAngle = meta.Normalize
    SLVBase.IsFixedNormalizeAngle = true
    function meta:Normalize()
        self:Set(NormalizeAngle(self))
        return self
    end
end
