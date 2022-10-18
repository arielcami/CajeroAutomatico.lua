NPC_ID = 60000

	function CC(A)  local f=A
  		while true do f, k = string.gsub(f, "^(-?%d+)(%d%d%d)", '%1,%2')
    	if (k==0) then break end end
  		return f
  	end

local function Click(e,P,U) local g=P:GetGUIDLow()
	P:GossipClearMenu()
	P:GossipMenuAddItem( 1, "Realizar depósito.", 	10, 1 ,true, "¿Cuánto oro deseas depositar?")
	P:GossipMenuAddItem( 6, "Retirar dinero.", 		10, 2, true, "¿Cuánto oro deseas retirar?" )
	P:GossipMenuAddItem( 4, "Consultar balance.", 	10, 3, nil, nil, nil)
	P:GossipSendMenu(1,U,MenuId)
end
-----------------------------------------------------------------------------------------------------------------------
local function MenuClick(e,P,U,S,I,C) 

	local coin=P:GetCoinage()
	local function bc(a) P:SendBroadcastMessage(a) end
	local function gc(b) P:GossipComplete() end

	local function Num(code) 
		n=tonumber(code)
		if n==nil then return 0 end
		if n<=0 then return 0 end
		if n<1 then return 0 end
		if n>=1 then 
			n=math.floor(n) return n
		end
	end

	if S==10 and I==3 then C=3 end

	if Num(C)==0 then
		bc('|cffff2b2bIngresa un valor válido, números mayores o iguales a 1.') return gc()
	else 
		N=Num(C)  Gold=N*10000  g=P:GetGUIDLow()
		if S==10 then
			if I==1 then								
				if coin>=Gold then
					CharDBExecute("UPDATE `aa_cajero` SET `money` = `money` + "..N.." WHERE `player`="..g.."")
					q=CharDBQuery("SELECT `money` FROM `aa_cajero` WHERE `player` = "..g.."")
					bc('|cffffd1f4¡Depósito realizado! Tu nuevo balance es: |cff00aeff$'..( CC(q:GetInt32(0)+N) ).."|cffffd1f4.") gc()
					P:ModifyMoney(-Gold)
				else
					bc('|cffff2b2bNo tienes esa cantidad de oro.') return gc()
				end
			end				
			if I==2 then
				if Gold+coin>=2000000000 then 
					bc("|cffff2b2bSi realizas este retiro acabarás con más de 200,000 de oro, lo cual no es recomendable. Divide tu retiro en retiros más pequeños.") return gc()
				else					
					q=CharDBQuery("SELECT `money` FROM `aa_cajero` WHERE `player` = "..g.."")
					if N>q:GetInt32(0) then 
						bc('|cffff2b2bNo posees esa cantidad en tus ahorros.') return gc()
					else
						CharDBExecute("UPDATE `aa_cajero` SET `money` = `money` - "..N.." WHERE `player`="..g.."")
						bc('|cffffd1f4¡Retiro realizado! Tu nuevo balance es: |cff00aeff$'..( CC(q:GetInt32(0)-N) ).."|cffffd1f4.") gc()
						P:ModifyMoney(Gold)
					end
				end
			end
			if I==3 then
				q=CharDBQuery("SELECT `money` FROM `aa_cajero` WHERE `player` = "..g.."")				
				bc("|cffffd1f4Tu Cuenta de Ahorros: |cff00aeff$"..( CC(q:GetInt32(0))).."")
				return
				Click(e,P,U)
			end
		end	
	end	
end
-----------------------------------------------------------------------------------------------------------------------
local function ElunaReload(ev)
	CharDBExecute("CREATE TABLE IF NOT EXISTS `aa_cajero` (`player` INT(10) NOT NULL UNIQUE, `money` MEDIUMINT(20))")
end
-----------------------------------------------------------------------------------------------------------------------
local function PlayerLogIn(e,P) local g=P:GetGUIDLow()
	CharDBExecute("INSERT IGNORE INTO `aa_cajero` (`player`,`money`) VALUES ("..g..", 0)")
end
-----------------------------------------------------------------------------------------------------------------------
RegisterCreatureGossipEvent(NPC_ID, 1, Click )
RegisterCreatureGossipEvent(NPC_ID, 2, MenuClick )
RegisterServerEvent(33, ElunaReload )
RegisterPlayerEvent(3, PlayerLogIn )