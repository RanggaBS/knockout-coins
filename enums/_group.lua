local Util = KNOCKOUT_COINS.Util;

(function()
  if Util.GetGameEdition() ~= 'SE' then return end

  local filenames = { 'Event' }
  for _, filename in ipairs(filenames) do
    LoadScript('enums/' .. filename .. '.lua')
  end
end)()
