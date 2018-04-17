/*

Skripta zapo�ena 6.12.2017

---------------------  TODO  -------------------------------
	=House system
	    ->Kupnja kuce
			-Novac se ne oduzima
			-Ime se duplicira, treba obrisat prije(BUG)
			-Neispravan prikaz 3DTextLabela(BUG)
	=Business System
	=Jobs System

*/

#include <a_samp>
#include <a_mysql>
#include <sscanf2>
#define dcmd(%1,%2,%3) if (!strcmp((%3)[1], #%1, true, (%2)) && ((((%3)[(%2) + 1] == '\0') && (dcmd_%1(playerid, ""))) || (((%3)[(%2) + 1] == ' ') && (dcmd_%1(playerid, (%3)[(%2) + 2]))))) return 1

#define MYSQL_HOST	"localhost"
#define MYSQL_USER	"root"
#define MYSQL_DB	"nullRP"
#define MYSQL_PASS 	""

#define MAX_HOUSES 500

#define KUCA_LEVEL 6

#define DIALOG_REGISTER 1
#define DIALOG_LOGIN 2
#define DIALOG_SUCCESS_1 3
#define DIALOG_SUCCESS_2 4
#define DIALOG_SUCCESS_REGISTER 5

#define BIJELA "{FFFFFF}"
#define SIVA "{C0C0C0}"
#define CRVENA "{F81414}"
#define ROZA "{D633D6}"
#define PLAVA "{0049FF}"
#define SPLAVA "{33CCFF}"
#define ZELENA "{6EF83C}"
#define ZUTA "{F3FF02}"

#define BOJA_SIVA 0xAFAFAFAA
#define BOJA_ZELENA 0x33AA33AA
#define BOJA_CRVENA 0xAA3333AA
#define BOJA_ZUTA 0xFFFF00AA
#define BOJA_BIJELA 0xFFFFFFAA
#define BOJA_PLAVA 0x0000BBAA
#define BOJA_NARANCASTA 0xFF9900AA
#define BOJA_CRNA 0x000000AA
#define BOJA_SMEDJA 0XA52A2AAA
#define BOJA_ZLATNA 0xB8860BAA
#define BOJA_ROZA 0xFFC0CBAA
#define BOJA_VOJNA 0x9ACD32AA

forward ProvjeraIgraca(playerid);
forward InfoIgraca(playerid);
forward Prijava(playerid);
forward UcitajVozila();
forward UcitajKuce();
forward NamjestiKoordinateKuca();

enum kLevelKordinate
{
	Float:kLx,
	Float:kLy,
	Float:kLz
}

enum iInfo
{
	ime[128],
	lozinka[128],
	email[50],
	novac,
	posao,
	admin,
	level,
	respect,
	organizacija,
	rank,
	skin
};
enum vInfo
{
	vId,
	vVlasnik[50],
	vSuvlasnik[50],
	vModel,
	Float:vPozX,
	Float:vPozY,
	Float:vPozZ,
	Float:vPozZkut,
	vBoja1,
	vBoja2,
	vMod1,
	vMod2
};
enum kInfo
{
	kId,
	kVlasnik[50],
	kSuvlasnik[50],
	Float:kX,
	Float:kY,
	Float:kZ,
	Float:kUx,
	Float:kUy,
	Float:kUz,
	kCijena,
	kZakljucano,
	Text3D:kTextid,
	kPickUpId,
	kInteriorId,
	kLevel
};

enum iStatus{
	registriran,
	logiran
};
enum gVrijednosti{
	auti,
	kuce
};

new MySql;

new igracInfo[MAX_PLAYERS][iInfo];
new igracStatus[MAX_PLAYERS][iStatus];

new voziloInfo[MAX_VEHICLES][vInfo];
new kucaInfo[MAX_HOUSES][kInfo];

new kucaLevel[KUCA_LEVEL][kLevelKordinate];

new PlayerText:TextDrawStats[MAX_PLAYERS][12];

new globalneVrijednosti[gVrijednosti];

#if defined FILTERSCRIPT

public OnFilterScriptInit()
{
	print("\n--------------------------------------");
	print(" Blank Filterscript by your name here");
	print("--------------------------------------\n");
	return 1;
}

public OnFilterScriptExit()
{
	return 1;
}

#else

main()
{

}

#endif

public OnGameModeInit()
{
	SetGameModeText("NullRP");
 	DisableInteriorEnterExits();
	EnableStuntBonusForAll(0);
	MySql = mysql_connect(MYSQL_HOST, MYSQL_USER, MYSQL_DB, MYSQL_PASS);
	print("Povezivanje baze...");
	if(MySql){
	    print("Baza uspjesno povezana!");
	    mysql_function_query(MySql, "SELECT * FROM vozila", true, "UcitajVozila", "");
	} else {
	    print("Nije moguce povezati bazu!");
	}
	return 1;
}

public UcitajVozila()
{
    new redovi, polje;
    cache_get_data(redovi, polje);
    if(redovi)
    {
        new i, temp[50], Float:tempfloat;
        print("Ucitavanje vozila...");
		for(i = 0; i < redovi; i++)
		{
			cache_get_row(i, 0, temp);
			voziloInfo[i][vId] = strval(temp);

			cache_get_row(i, 1, temp);
			voziloInfo[i][vVlasnik] = temp;

			temp="";
			cache_get_row(i, 2, temp);
			voziloInfo[i][vSuvlasnik] = temp;

			cache_get_row(i, 3, temp);
			voziloInfo[i][vModel] = strval(temp);

			cache_get_row(i, 4, temp);
			sscanf(temp, "f", tempfloat);
			voziloInfo[i][vPozX] = tempfloat;

			cache_get_row(i, 5, temp);
			sscanf(temp, "f", tempfloat);
			voziloInfo[i][vPozY] = tempfloat;

			cache_get_row(i, 6, temp);
			sscanf(temp, "f", tempfloat);
			voziloInfo[i][vPozZ] = tempfloat;

			cache_get_row(i, 7, temp);
			sscanf(temp, "f", tempfloat);
			voziloInfo[i][vPozZkut] = tempfloat;

			cache_get_row(i, 8, temp);
			voziloInfo[i][vBoja1] = strval(temp);

			cache_get_row(i, 9, temp);
			voziloInfo[i][vBoja2] = strval(temp);

			temp="";
			cache_get_row(i, 10, temp);
			voziloInfo[i][vMod1] = strval(temp);

			temp="";
			cache_get_row(i, 11, temp);
			voziloInfo[i][vMod2] = strval(temp);

            voziloInfo[i][vId]=CreateVehicle(voziloInfo[i][vModel], voziloInfo[i][vPozX], voziloInfo[i][vPozY], voziloInfo[i][vPozZ], voziloInfo[i][vPozZkut], voziloInfo[i][vBoja1], voziloInfo[i][vBoja2],-1,0);
  			//printf("Vozilo ID= %d spawnano na ModelID=%d, X=%f, Y=%f, Z=%f, R=%f, Vlasnik:%s Index:%d", voziloInfo[i][vId],voziloInfo[i][vModel], voziloInfo[i][vPozX], voziloInfo[i][vPozY], voziloInfo[i][vPozZ], voziloInfo[i][vPozZkut], voziloInfo[i][vVlasnik], i);
			printf("Vozilo spawnano, ID=%d, Model=%d, Vlasnik=%s, Suvlasnik=%s", voziloInfo[i][vId], voziloInfo[i][vModel], voziloInfo[i][vVlasnik], voziloInfo[i][vSuvlasnik]);
		}
	}
	globalneVrijednosti[auti] = redovi;
	printf("Ucitano vozila: %d", globalneVrijednosti[auti]);
	mysql_function_query(MySql, "SELECT * FROM kuce", true, "UcitajKuce", "");
}

public UcitajKuce()
{
	new redovi, polje;
 	cache_get_data(redovi, polje);
 	print("Ucitavanje kuca...");
 	if(redovi)
 	{
        new i, temp[50], Float:tempfloat;
        new textlabel[128];
        for(i=0;i<redovi;i++)
		{
            cache_get_row(i, 0, temp);
			kucaInfo[i][kId] = strval(temp);

			cache_get_row(i, 1, temp);
			kucaInfo[i][kVlasnik] = temp;

			cache_get_row(i, 2, temp);
			kucaInfo[i][kSuvlasnik] = temp;

			cache_get_row(i, 3, temp);
			sscanf(temp, "f", tempfloat);
			kucaInfo[i][kX] = tempfloat;

			cache_get_row(i, 4, temp);
			sscanf(temp, "f", tempfloat);
			kucaInfo[i][kY] = tempfloat;

			cache_get_row(i, 5, temp);
			sscanf(temp, "f", tempfloat);
			kucaInfo[i][kZ] = tempfloat;

			cache_get_row(i, 6, temp);
			sscanf(temp, "f", tempfloat);
			kucaInfo[i][kUx] = tempfloat;

			cache_get_row(i, 7, temp);
			sscanf(temp, "f", tempfloat);
			kucaInfo[i][kUy] = tempfloat;

			cache_get_row(i, 8, temp);
			sscanf(temp, "f", tempfloat);
			kucaInfo[i][kUz] = tempfloat;

			cache_get_row(i, 9, temp);
			kucaInfo[i][kCijena] = strval(temp);

			cache_get_row(i, 10, temp);
			kucaInfo[i][kZakljucano] = strval(temp);

			cache_get_row(i, 11, temp);
			kucaInfo[i][kInteriorId] = strval(temp);

			cache_get_row(i, 12, temp);
			kucaInfo[i][kLevel] = strval(temp);

			new velicina[20];
		   	if(kucaInfo[i][kLevel]==0) velicina="Vikendica";
		   	else if(kucaInfo[i][kLevel]==1) velicina="Apartman";
		   	else if(kucaInfo[i][kLevel]==2) velicina="Mala kuća";
		   	else if(kucaInfo[i][kLevel]==3) velicina="Srednja kuća";
		   	else if(kucaInfo[i][kLevel]==4) velicina="Velika kuća";
		   	else if(kucaInfo[i][kLevel]==5) velicina="Vila";

			if(strcmp(kucaInfo[i][kVlasnik], "ZaProdaju", false) == 0)
			{
			    format(textlabel,sizeof(textlabel), ""CRVENA"%s "ZELENA"na prodaju!\nID: {FFFFFF}%d\n "ZUTA"Cijena: {FFFFFF}%d",velicina, kucaInfo[i][kId], kucaInfo[i][kCijena]);
			    kucaInfo[i][kPickUpId]=CreatePickup(1273, 0, kucaInfo[i][kX], kucaInfo[i][kY], kucaInfo[i][kZ], 0);
			}
			else
			{
			    format(textlabel,sizeof(textlabel), ""CRVENA"%s\n"SPLAVA"Vlasnik: "CRVENA"%s\n{27E313}ID: "BIJELA"%d", velicina, kucaInfo[i][kVlasnik], kucaInfo[i][kId]);
			    kucaInfo[i][kPickUpId]=CreatePickup(1272, 0, kucaInfo[i][kX], kucaInfo[i][kY], kucaInfo[i][kZ], 0);
			}
            kucaInfo[i][kTextid] = Create3DTextLabel(textlabel, BOJA_CRVENA, kucaInfo[i][kX], kucaInfo[i][kY], kucaInfo[i][kZ], 40.0, 0, 0);
            printf("Kuca kreirana na kordinatama X: %f, Y: %f, Z: %f, vlasnik: %s", kucaInfo[i][kX], kucaInfo[i][kY], kucaInfo[i][kZ], kucaInfo[i][kVlasnik]);
		}
		globalneVrijednosti[kuce] = redovi;
		printf("Ucitano kuca: %d", globalneVrijednosti[kuce]);
		mysql_function_query(MySql, "SELECT * FROM koordinate WHERE kategorija='kuce'", true, "NamjestiKoordinateKuca", "");
	}
	else
	{
		print("Nema kuca");
	}
}

public NamjestiKoordinateKuca()
{
    new redovi, polje, kucalevel, kategorija[20];
 	cache_get_data(redovi, polje);
 	print("Ucitavanje koordinata...");
 	if(redovi)
 	{
        new i, temp[50], Float:tempfloat;
        for(i=0;i<redovi;i++)
		{
		    cache_get_row(i, 1, kategorija);

			cache_get_row(i, 2, temp);
			kucalevel = strval(temp);

			cache_get_row(i, 3, temp);
			sscanf(temp, "f", tempfloat);
			kucaLevel[i][kLx] = tempfloat;

			cache_get_row(i, 4, temp);
			sscanf(temp, "f", tempfloat);
			kucaLevel[i][kLy] = tempfloat;

			cache_get_row(i, 5, temp);
			sscanf(temp, "f", tempfloat);
			kucaLevel[i][kLz] = tempfloat;

			printf("Ucitane koordiante %s levela:%d, koordinate x: %f, koordinate y: %f, koordinate z: %f", kategorija, kucalevel, kucaLevel[i][kLx], kucaLevel[i][kLy], kucaLevel[i][kLz]);
		}
		print("Ucitavanje koordinata zavrseno!");
	}
}

public OnGameModeExit()
{
	print("Zatvaranje baze...");
	mysql_close(MySql);
	print("Baza zatvorena!");
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	//SetPlayerPos(playerid, 1958.3783, 1343.1572, 15.3746);
	//SetPlayerCameraPos(playerid, 1958.3783, 1343.1572, 15.3746);
	//SetPlayerCameraLookAt(playerid, 1958.3783, 1343.1572, 15.3746);
	return 1;
}

public OnPlayerConnect(playerid)
{
    new query[128];
    GetPlayerName(playerid, igracInfo[playerid][ime], MAX_PLAYER_NAME);
	format(query, sizeof(query), "SELECT * FROM igraci WHERE ime = BINARY '%s'", igracInfo[playerid][ime]);
    mysql_function_query(MySql, query, true, "ProvjeraIgraca", "i", playerid);

	TextDrawStats[playerid][1] = CreatePlayerTextDraw(playerid, 521.918029, 134.583343, "Level:");
	PlayerTextDrawLetterSize(playerid, TextDrawStats[playerid][1], 0.324391, 0.901665);
	PlayerTextDrawTextSize(playerid, TextDrawStats[playerid][1], 618.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, TextDrawStats[playerid][1], 1);
	PlayerTextDrawColor(playerid, TextDrawStats[playerid][1], -1);
	PlayerTextDrawUseBox(playerid, TextDrawStats[playerid][1], 1);
	PlayerTextDrawBoxColor(playerid, TextDrawStats[playerid][1], 83);
	PlayerTextDrawSetShadow(playerid, TextDrawStats[playerid][1], 0);
	PlayerTextDrawSetOutline(playerid, TextDrawStats[playerid][1], 0);
	PlayerTextDrawBackgroundColor(playerid, TextDrawStats[playerid][1], 0);
	PlayerTextDrawFont(playerid, TextDrawStats[playerid][1], 1);
	PlayerTextDrawSetProportional(playerid, TextDrawStats[playerid][1], 1);
	PlayerTextDrawSetShadow(playerid, TextDrawStats[playerid][1], 0);

	TextDrawStats[playerid][2] = CreatePlayerTextDraw(playerid, 521.918090, 147.416671, "Respekti:");
	PlayerTextDrawLetterSize(playerid, TextDrawStats[playerid][2], 0.324391, 0.901665);
	PlayerTextDrawTextSize(playerid, TextDrawStats[playerid][2], 618.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, TextDrawStats[playerid][2], 1);
	PlayerTextDrawColor(playerid, TextDrawStats[playerid][2], -1);
	PlayerTextDrawUseBox(playerid, TextDrawStats[playerid][2], 1);
	PlayerTextDrawBoxColor(playerid, TextDrawStats[playerid][2], 83);
	PlayerTextDrawSetShadow(playerid, TextDrawStats[playerid][2], 0);
	PlayerTextDrawSetOutline(playerid, TextDrawStats[playerid][2], 0);
	PlayerTextDrawBackgroundColor(playerid, TextDrawStats[playerid][2], 0);
	PlayerTextDrawFont(playerid, TextDrawStats[playerid][2], 1);
	PlayerTextDrawSetProportional(playerid, TextDrawStats[playerid][2], 1);
	PlayerTextDrawSetShadow(playerid, TextDrawStats[playerid][2], 0);

	TextDrawStats[playerid][3] = CreatePlayerTextDraw(playerid, 521.918090, 160.249984, "Posao:");
	PlayerTextDrawLetterSize(playerid, TextDrawStats[playerid][3], 0.324391, 0.901665);
	PlayerTextDrawTextSize(playerid, TextDrawStats[playerid][3], 618.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, TextDrawStats[playerid][3], 1);
	PlayerTextDrawColor(playerid, TextDrawStats[playerid][3], -1);
	PlayerTextDrawUseBox(playerid, TextDrawStats[playerid][3], 1);
	PlayerTextDrawBoxColor(playerid, TextDrawStats[playerid][3], 83);
	PlayerTextDrawSetShadow(playerid, TextDrawStats[playerid][3], 0);
	PlayerTextDrawSetOutline(playerid, TextDrawStats[playerid][3], 0);
	PlayerTextDrawBackgroundColor(playerid, TextDrawStats[playerid][3], 0);
	PlayerTextDrawFont(playerid, TextDrawStats[playerid][3], 1);
	PlayerTextDrawSetProportional(playerid, TextDrawStats[playerid][3], 1);
	PlayerTextDrawSetShadow(playerid, TextDrawStats[playerid][3], 0);

	TextDrawStats[playerid][4] = CreatePlayerTextDraw(playerid, 521.918090, 173.083297, "Org:");
	PlayerTextDrawLetterSize(playerid, TextDrawStats[playerid][4], 0.324391, 0.901665);
	PlayerTextDrawTextSize(playerid, TextDrawStats[playerid][4], 618.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, TextDrawStats[playerid][4], 1);
	PlayerTextDrawColor(playerid, TextDrawStats[playerid][4], -1);
	PlayerTextDrawUseBox(playerid, TextDrawStats[playerid][4], 1);
	PlayerTextDrawBoxColor(playerid, TextDrawStats[playerid][4], 83);
	PlayerTextDrawSetShadow(playerid, TextDrawStats[playerid][4], 0);
	PlayerTextDrawSetOutline(playerid, TextDrawStats[playerid][4], 0);
	PlayerTextDrawBackgroundColor(playerid, TextDrawStats[playerid][4], 0);
	PlayerTextDrawFont(playerid, TextDrawStats[playerid][4], 1);
	PlayerTextDrawSetProportional(playerid, TextDrawStats[playerid][4], 1);
	PlayerTextDrawSetShadow(playerid, TextDrawStats[playerid][4], 0);

	TextDrawStats[playerid][7] = CreatePlayerTextDraw(playerid, 576.591857, 135.166580, " ");
	PlayerTextDrawLetterSize(playerid, TextDrawStats[playerid][7], 0.258506, 1.022498);
	PlayerTextDrawAlignment(playerid, TextDrawStats[playerid][7], 2);
	PlayerTextDrawColor(playerid, TextDrawStats[playerid][7], -1);
	PlayerTextDrawSetShadow(playerid, TextDrawStats[playerid][7], 0);
	PlayerTextDrawSetOutline(playerid, TextDrawStats[playerid][7], 0);
	PlayerTextDrawBackgroundColor(playerid, TextDrawStats[playerid][7], 255);
	PlayerTextDrawFont(playerid, TextDrawStats[playerid][7], 1);
	PlayerTextDrawSetProportional(playerid, TextDrawStats[playerid][7], 1);
	PlayerTextDrawSetShadow(playerid, TextDrawStats[playerid][7], 0);

	TextDrawStats[playerid][8] = CreatePlayerTextDraw(playerid, 589.853637, 147.999923, " ");
	PlayerTextDrawLetterSize(playerid, TextDrawStats[playerid][8], 0.258506, 1.022498);
	PlayerTextDrawAlignment(playerid, TextDrawStats[playerid][8], 2);
	PlayerTextDrawColor(playerid, TextDrawStats[playerid][8], -1);
	PlayerTextDrawSetShadow(playerid, TextDrawStats[playerid][8], 0);
	PlayerTextDrawSetOutline(playerid, TextDrawStats[playerid][8], 0);
	PlayerTextDrawBackgroundColor(playerid, TextDrawStats[playerid][8], 255);
	PlayerTextDrawFont(playerid, TextDrawStats[playerid][8], 1);
	PlayerTextDrawSetProportional(playerid, TextDrawStats[playerid][8], 1);
	PlayerTextDrawSetShadow(playerid, TextDrawStats[playerid][8], 0);

	TextDrawStats[playerid][9] = CreatePlayerTextDraw(playerid, 582.751647, 160.449905, " ");
	PlayerTextDrawLetterSize(playerid, TextDrawStats[playerid][9], 0.258506, 1.022498);
	PlayerTextDrawAlignment(playerid, TextDrawStats[playerid][9], 2);
	PlayerTextDrawColor(playerid, TextDrawStats[playerid][9], -1);
	PlayerTextDrawSetShadow(playerid, TextDrawStats[playerid][9], 0);
	PlayerTextDrawSetOutline(playerid, TextDrawStats[playerid][9], 0);
	PlayerTextDrawBackgroundColor(playerid, TextDrawStats[playerid][9], 255);
	PlayerTextDrawFont(playerid, TextDrawStats[playerid][9], 1);
	PlayerTextDrawSetProportional(playerid, TextDrawStats[playerid][9], 1);
	PlayerTextDrawSetShadow(playerid, TextDrawStats[playerid][9], 0);

	TextDrawStats[playerid][10] = CreatePlayerTextDraw(playerid, 582.745483, 173.083206, " ");
	PlayerTextDrawLetterSize(playerid, TextDrawStats[playerid][10], 0.258506, 1.022498);
	PlayerTextDrawAlignment(playerid, TextDrawStats[playerid][10], 2);
	PlayerTextDrawColor(playerid, TextDrawStats[playerid][10], -1);
	PlayerTextDrawSetShadow(playerid, TextDrawStats[playerid][10], 0);
	PlayerTextDrawSetOutline(playerid, TextDrawStats[playerid][10], 0);
	PlayerTextDrawBackgroundColor(playerid, TextDrawStats[playerid][10], 255);
	PlayerTextDrawFont(playerid, TextDrawStats[playerid][10], 1);
	PlayerTextDrawSetProportional(playerid, TextDrawStats[playerid][10], 1);
	PlayerTextDrawSetShadow(playerid, TextDrawStats[playerid][10], 0);
	return 1;
}

public ProvjeraIgraca(playerid)
{
    new redovi, polja;
    cache_get_data(redovi, polja);
    if(redovi)
    {
		igracStatus[playerid][registriran] = 1;
		ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD,"Prijava","Unesi lozinku ispod za prijavu.","Prijava","Odustani");

    } else {
    	igracStatus[playerid][registriran] = 0;
    	ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_INPUT,"Registracija","Unesi lozinku za registraciju racuna","Registracija","Odustani");
    }
    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    new query[256];
	format(query, sizeof(query), "UPDATE igraci SET novac = %d, posao = %d, admin=%d, level=%d, respect=%d, organizacija=%d, rank=%d, skin=%d WHERE name = '%s'", igracInfo[playerid][novac], igracInfo[playerid][posao], igracInfo[playerid][admin], igracInfo[playerid][level],igracInfo[playerid][respect],igracInfo[playerid][organizacija], igracInfo[playerid][rank], igracInfo[playerid][skin], igracInfo[playerid][ime]);
	mysql_function_query(MySql, query, false, "", "");
	printf("[IGRAC-ODJAVA]%s se odjavio", igracInfo[playerid][ime]);
	return 1;
}

public OnPlayerSpawn(playerid)
{
	if(!igracStatus[playerid][logiran]){
        SendClientMessage(playerid, 0xFF0000AA, "Nisi prijavljen!");
        SetTimerEx("Kick",500,false,"i",playerid);
    }
	else
	{
		SetPlayerPos(playerid, -1498.3866,920.1454,7.1875); // San Fierro Pier Spawn
		//GivePlayerMoney(playerid, 10000000);
		SetTimerEx("InfoIgraca",5000,true, "i", playerid);
		PlayerTextDrawShow(playerid, TextDrawStats[playerid][0]);
		PlayerTextDrawShow(playerid, TextDrawStats[playerid][1]);
		PlayerTextDrawShow(playerid, TextDrawStats[playerid][2]);
		PlayerTextDrawShow(playerid, TextDrawStats[playerid][3]);
		PlayerTextDrawShow(playerid, TextDrawStats[playerid][4]);
		PlayerTextDrawShow(playerid, TextDrawStats[playerid][5]);
		PlayerTextDrawShow(playerid, TextDrawStats[playerid][6]);
		PlayerTextDrawShow(playerid, TextDrawStats[playerid][7]);
		PlayerTextDrawShow(playerid, TextDrawStats[playerid][8]);
		PlayerTextDrawShow(playerid, TextDrawStats[playerid][9]);
		PlayerTextDrawShow(playerid, TextDrawStats[playerid][10]);
		PlayerTextDrawShow(playerid, TextDrawStats[playerid][11]);

		if(!strcmp(igracInfo[playerid][email], "0"))
             SendClientMessage(playerid, BOJA_CRVENA, "Nemas une�en mail, unesi ga sa /email <email>");

	}
	return 1;
}

public InfoIgraca(playerid)
{
	new lvl[4],res[4];

	valstr(lvl,igracInfo[playerid][level]);
	valstr(res,igracInfo[playerid][respect]);

    PlayerTextDrawSetString(playerid, TextDrawStats[playerid][7], lvl);
    PlayerTextDrawSetString(playerid, TextDrawStats[playerid][8], res);

    if(igracInfo[playerid][posao]==0) PlayerTextDrawSetString(playerid, TextDrawStats[playerid][9], "Nezaposlen");
    else PlayerTextDrawSetString(playerid, TextDrawStats[playerid][9], "-");

    if(igracInfo[playerid][organizacija]==0) PlayerTextDrawSetString(playerid, TextDrawStats[playerid][10], "Nisi u org");
    else PlayerTextDrawSetString(playerid, TextDrawStats[playerid][10], "-");
	return 1;
}


public OnPlayerDeath(playerid, killerid, reason)
{
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

public OnPlayerText(playerid, text[])
{
	return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	dcmd(email, 5, cmdtext);
	dcmd(tp, 2, cmdtext);
	dcmd(nazad, 5, cmdtext);
	dcmd(testinterior, 12, cmdtext);
	dcmd(postavikucu, 11, cmdtext);
	dcmd(udji, 4, cmdtext);
	dcmd(izadji, 6, cmdtext);
	dcmd(kupikucu, 8, cmdtext);
	return 0;
}

dcmd_email(playerid, params[])
{
	new mail[50], query[256];
	if(!strlen(params)) return SendClientMessage(playerid, BOJA_NARANCASTA, "Koristenje /email <email>!");
	sscanf(params, "s", mail);
    igracInfo[playerid][email]=mail;
 	format(query, sizeof(query), "UPDATE igraci SET email = '%s' WHERE ime = '%s'", igracInfo[playerid][email], igracInfo[playerid][ime]);
	mysql_function_query(MySql, query, false, "", "");
	return SendClientMessage(playerid, BOJA_ZELENA, "Uspje�no si dodao svoj email!");
}
dcmd_tp(playerid, params[])
{
	new Float:x,Float:y,Float:z;
	if(!strlen(params)) return SendClientMessage(playerid, BOJA_NARANCASTA, "Koristenje /tp <x> <y> <z>!");
	sscanf(params, "fff", x,y,z);
 	SetPlayerPos(playerid, x, y, z);
	return SendClientMessage(playerid, BOJA_ZELENA, "Uspje�no si se teleportirao!");
}

dcmd_nazad(playerid, params[])
{
	#pragma unused params
 	SetPlayerPos(playerid, -1498.3866,920.1454,7.1875);
 	SetPlayerInterior(playerid, 0);
	return SendClientMessage(playerid, BOJA_ZELENA, "Uspje�no si se teleportirao nazad na spawn!");
}

dcmd_testinterior(playerid, params[])
{
	new id;
	if(!strlen(params)) return SendClientMessage(playerid, BOJA_NARANCASTA, "Koristenje /interior <id>!");
	sscanf(params, "d", id);
	if(id==15){
        SetPlayerPos(playerid, 295.138977, 1474.469971, 1080.519897);
       	SetPlayerInterior(playerid, 15);
       	return SendClientMessage(playerid, BOJA_ZELENA, "Uspje�no si se teleportirao!");
	}
	else{
        return SendClientMessage(playerid, BOJA_CRVENA, "Pogreska!");
	}
}

dcmd_postavikucu(playerid, params[])
{
	new Float:x,Float:y,Float:z, cijena, novi_id, level_kuce;
	if(igracInfo[playerid][admin]<2) return SendClientMessage(playerid, BOJA_CRVENA, "Nisi admin, nemozes koristiti ovu komandu!");
	if(!strlen(params)) return SendClientMessage(playerid, BOJA_NARANCASTA, "Koristenje /postavikucu <cijena> <level>");
	sscanf(params, "dd", cijena, level_kuce);
	if(cijena<=0) return SendClientMessage(playerid, BOJA_CRVENA, "Cijena nesmije biti 0 ili manje!");
	if(level_kuce<0 || level_kuce>5) return SendClientMessage(playerid, BOJA_CRVENA, "Level mora biti u rasponu od 0 do 5!");

	GetPlayerPos(playerid, x, y, z);
 	novi_id=globalneVrijednosti[kuce]+1;

 	kucaInfo[novi_id][kId]=novi_id;
 	strins(kucaInfo[novi_id][kVlasnik], "ZaProdaju", 0);
    strins(kucaInfo[novi_id][kSuvlasnik], "Nitko", 0);
    kucaInfo[novi_id][kX]=x;
    kucaInfo[novi_id][kY]=y;
    kucaInfo[novi_id][kZ]=z;
    kucaInfo[novi_id][kUx]=kucaLevel[level_kuce][kLx];
    kucaInfo[novi_id][kUy]=kucaLevel[level_kuce][kLy];
    kucaInfo[novi_id][kUz]=kucaLevel[level_kuce][kLz];
    kucaInfo[novi_id][kCijena]=cijena;
    kucaInfo[novi_id][kLevel]=level_kuce;

    new velicina[20], textlabel[128];
   	if(kucaInfo[novi_id][kLevel]==0){
	   velicina="Vikendica";
	   kucaInfo[novi_id][kInteriorId]=15;
  	}
   	else if(kucaInfo[novi_id][kLevel]==1){
	   velicina="Apartman";
	   kucaInfo[novi_id][kInteriorId]=1;
  	}
   	else if(kucaInfo[novi_id][kLevel]==2){
	   velicina="Mala ku�a";
	   kucaInfo[novi_id][kInteriorId]=15;
  	}
   	else if(kucaInfo[novi_id][kLevel]==3){
	   velicina="Srednja ku�a";
	   kucaInfo[novi_id][kInteriorId]=7;
  	}
   	else if(kucaInfo[novi_id][kLevel]==4){
	   velicina="Velika ku�a";
	   kucaInfo[novi_id][kInteriorId]=3;
  	}
   	else if(kucaInfo[novi_id][kLevel]==5){
	   velicina="Vila";
	   kucaInfo[novi_id][kInteriorId]=2;
  	}

    format(textlabel,sizeof(textlabel), ""CRVENA"%s "ZELENA"na prodaju!\nID: {FFFFFF}%d\n "ZUTA"Cijena: {FFFFFF}%d",velicina, kucaInfo[novi_id][kId], kucaInfo[novi_id][kCijena]);
    kucaInfo[novi_id][kTextid] = Create3DTextLabel(textlabel, BOJA_CRVENA, kucaInfo[novi_id][kX], kucaInfo[novi_id][kY], kucaInfo[novi_id][kZ], 40.0, 0, 0);
    kucaInfo[novi_id][kPickUpId]=CreatePickup(1273, 0, kucaInfo[novi_id][kX], kucaInfo[novi_id][kY], kucaInfo[novi_id][kZ], 0);

    new query1[1000];
    new query2[1000];
    format(query1, sizeof(query1), "INSERT INTO kuce (vlasnik, suvlasnik, x, y, z, unutraX, unutraY, unutraZ, cijena, zakljucano, interiorId, level) ");
    format(query2, sizeof(query2), "VALUES ('%s', '%s', '%f', '%f', '%f', '%f', '%f', '%f', '%d', '%d', '%d', '%d')", kucaInfo[novi_id][kVlasnik], kucaInfo[novi_id][kSuvlasnik], kucaInfo[novi_id][kX], kucaInfo[novi_id][kY], kucaInfo[novi_id][kZ], kucaInfo[novi_id][kUx], kucaInfo[novi_id][kUy], kucaInfo[novi_id][kUz], kucaInfo[novi_id][kCijena], 0, kucaInfo[novi_id][kInteriorId], kucaInfo[novi_id][kLevel]);
	strins(query2, query1, 0);
	mysql_function_query(MySql, query2, false, "", "");

	printf("Stvorena nova kuca! '%s', '%s', '%f', '%f', '%f', '%f', '%f', '%f', '%d', '%d', '%d', '%d'", kucaInfo[novi_id][kVlasnik], kucaInfo[novi_id][kSuvlasnik], kucaInfo[novi_id][kX], kucaInfo[novi_id][kY], kucaInfo[novi_id][kZ], kucaInfo[novi_id][kUx], kucaInfo[novi_id][kUy], kucaInfo[novi_id][kUz], kucaInfo[novi_id][kCijena], 0, kucaInfo[novi_id][kInteriorId], kucaInfo[novi_id][kLevel]);

	globalneVrijednosti[kuce]++;

	return SendClientMessage(playerid, BOJA_ZELENA, "Uspje�no si kreirao kucu!");
}

dcmd_udji(playerid, params[])
{
	#pragma unused params
 	new Float:x,Float:y,Float:z, velicina, interior_id, imeIgraca[50];
 	GetPlayerPos(playerid, x, y, z);
 	GetPlayerName(playerid, imeIgraca, sizeof(imeIgraca));
 	velicina=globalneVrijednosti[kuce];
 	for(new i=0;i<velicina;i++){
		if(IsPlayerInRangeOfPoint(playerid, 5.0, kucaInfo[i][kX], kucaInfo[i][kY], kucaInfo[i][kZ])){
			if(kucaInfo[i][kZakljucano]==0){
				x=kucaInfo[i][kUx];
                y=kucaInfo[i][kUy];
                z=kucaInfo[i][kUz];
                interior_id=kucaInfo[i][kInteriorId];
                //printf("Ulaz u ku�i ID: %d LEVEL: %d InteriorID: %d, X:%f, Y:%f, Z:%f", kucaInfo[i][kId], kucaInfo[i][kLevel], interior_id, x, y, z);
                SetPlayerPos(playerid, x, y, z);
       			SetPlayerInterior(playerid, interior_id);
       			if(strcmp(kucaInfo[i][kVlasnik], imeIgraca, false)==0 || strcmp(kucaInfo[i][kSuvlasnik], imeIgraca, false)==0){
                    return SendClientMessage(playerid, BOJA_ZELENA, "Dobrodo�ao nazad!");
				}
			    else if(strcmp(kucaInfo[i][kVlasnik], "ZaProdaju", false)==0){
                    return SendClientMessage(playerid, BOJA_VOJNA, "Ova ku�a je na prodaju, pogledaj prije nego kupi�!");
				}
			    else{
                    return SendClientMessage(playerid, BOJA_CRVENA, "Provalio si u ku�u!");
				}
			}
			else{
			    return SendClientMessage(playerid, BOJA_CRVENA, "Zaklju�ano!");
			}
		}
	}
	return SendClientMessage(playerid, BOJA_CRVENA, "Nisi u blizini ulaza!");
}

dcmd_izadji(playerid, params[])
{
	#pragma unused params
 	new Float:x,Float:y,Float:z, velicina, interior_id, imeIgraca[50];
 	GetPlayerPos(playerid, x, y, z);
 	GetPlayerName(playerid, imeIgraca, sizeof(imeIgraca));
 	velicina=globalneVrijednosti[kuce];
 	for(new i=0;i<velicina;i++){
		if(IsPlayerInRangeOfPoint(playerid, 5.0, kucaInfo[i][kUx], kucaInfo[i][kUy], kucaInfo[i][kUz])){
			if(kucaInfo[i][kZakljucano]==0){
				x=kucaInfo[i][kX];
                y=kucaInfo[i][kY];
                z=kucaInfo[i][kZ];
                interior_id=0;
                //printf("Ulaz u ku�i ID: %d LEVEL: %d InteriorID: %d, X:%f, Y:%f, Z:%f", kucaInfo[i][kId], kucaInfo[i][kLevel], interior_id, x, y, z);
                SetPlayerPos(playerid, x, y, z);
       			SetPlayerInterior(playerid, interior_id);
       			return 0;
			}
			else{
			    return SendClientMessage(playerid, BOJA_CRVENA, "Zaklju�ano!");
			}
		}
	}
	return SendClientMessage(playerid, BOJA_CRVENA, "Nisi u blizini izlaza!");
}

dcmd_kupikucu(playerid, params[])
{
	#pragma unused params
 	new Float:x,Float:y,Float:z, imeIgraca[50], novacIgrac, ucitaneKuce, textlabel[128], query[128];
 	GetPlayerPos(playerid, x, y, z);
 	ucitaneKuce=globalneVrijednosti[kuce];
 	GetPlayerName(playerid, imeIgraca, sizeof(imeIgraca));
 	for(new i=0;i<ucitaneKuce;i++){
		if(IsPlayerInRangeOfPoint(playerid, 5.0, kucaInfo[i][kX], kucaInfo[i][kY], kucaInfo[i][kZ])){
			if(strcmp(kucaInfo[i][kVlasnik], "ZaProdaju", false)==0){
                novacIgrac=GetPlayerMoney(playerid);
                if(kucaInfo[i][kCijena]<=novacIgrac){
               		strdel(kucaInfo[i][kVlasnik], 0, strlen(kucaInfo[i][kVlasnik]));
					strins(kucaInfo[i][kVlasnik], imeIgraca, 0);
					DestroyPickup(kucaInfo[i][kPickUpId]);
					kucaInfo[i][kPickUpId]=CreatePickup(1272, 0, kucaInfo[i][kX], kucaInfo[i][kY], kucaInfo[i][kZ], 0);
					Delete3DTextLabel(kucaInfo[i][kTextid]);
					new velicina[20];
				  	if(kucaInfo[i][kLevel]==0) velicina="Vikendica";
				  	else if(kucaInfo[i][kLevel]==1) velicina="Apartman";
				  	else if(kucaInfo[i][kLevel]==2) velicina="Mala kuća";
				  	else if(kucaInfo[i][kLevel]==3) velicina="Srednja kuća";
				  	else if(kucaInfo[i][kLevel]==4) velicina="Velika kuća";
				  	else if(kucaInfo[i][kLevel]==5) velicina="Vila";
					format(textlabel,sizeof(textlabel), ""CRVENA"%s\n"SPLAVA"Vlasnik: "CRVENA"%s\n{27E313}ID: "BIJELA"%d", velicina, kucaInfo[i][kVlasnik], kucaInfo[i][kId]);
     				kucaInfo[i][kTextid] = Create3DTextLabel(textlabel, BOJA_CRVENA, kucaInfo[i][kX], kucaInfo[i][kY], kucaInfo[i][kZ], 40.0, 0, 0);
         			ResetPlayerMoney(playerid);
        			novacIgrac-=kucaInfo[i][kCijena];
          			igracInfo[playerid][novac]=novacIgrac;
					GivePlayerMoney(playerid, novacIgrac);
					format(query, sizeof(query), "UPDATE kuce SET vlasnik='%s' WHERE id='%d'", kucaInfo[i][kVlasnik], kucaInfo[i][kId]);
          			mysql_function_query(MySql, query, false, "", "");

          			return SendClientMessage(playerid, BOJA_ZELENA, "Uspjesno si kupio ku�u!");
				}
				else{
        	return SendClientMessage(playerid, BOJA_CRVENA, "Nema� dovoljno novca za ovu ku�u!");
				}
			}
			else{
      	return SendClientMessage(playerid, BOJA_CRVENA, "Ova ku�a nije na prodaju!");
			}
		}
	}
	return SendClientMessage(playerid, BOJA_CRVENA, "Nisi u blizini niti jedne ku�e!");
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	new i;
	for(i=0;i<MAX_VEHICLES;i++){
		if(voziloInfo[i][vId]==vehicleid){
			if(!strcmp(voziloInfo[i][vVlasnik], igracInfo[playerid][ime])){
                return SendClientMessage(playerid, BOJA_ZELENA, "Ovo je va�e vozilo!");
			}
			else if(!strcmp(voziloInfo[i][vSuvlasnik], igracInfo[playerid][ime])) {
                return SendClientMessage(playerid, BOJA_PLAVA, "Vi ste suvlasnik ovog vozila!");
			}else {
                return SendClientMessage(playerid, BOJA_NARANCASTA, "Niste vlasnik ovog vozila");
			}
		}
	}
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	return 1;
}

public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}

public OnPlayerUpdate(playerid)
{
	return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    new query[256];

	switch( dialogid )
    {
        case DIALOG_LOGIN:
        {
            if ( !response ) return Kick ( playerid );
            if( response )
            {
                format(query, sizeof(query), "SELECT * FROM igraci WHERE ime = BINARY '%s' AND lozinka = BINARY '%s'", igracInfo[playerid][ime], inputtext);
			 	mysql_function_query(MySql, query, true, "Prijava", "i", playerid);
            }
        }
        case DIALOG_REGISTER:
        {
            if ( !response ) return Kick ( playerid );
            if( response )
            {
                format(query, sizeof(query), "INSERT INTO igraci (ime, lozinka) VALUES ('%s', '%s')", igracInfo[playerid][ime], inputtext);
			 	mysql_function_query(MySql, query, false, "", "");
			 	igracStatus[playerid][logiran] = 1;
			 	igracStatus[playerid][registriran] = 1;
				ShowPlayerDialog(playerid, DIALOG_SUCCESS_REGISTER, DIALOG_STYLE_MSGBOX,"Registracija","Uspjesno si se registrirao!","Ok","");
				SetSpawnInfo(playerid, 0, 1, -1498.3866,920.1454,7.1875, 89.4492, 0,0,0,0,0,0);
				SpawnPlayer(playerid);
            }
        }
	}
	return 1;
}

public Prijava(playerid)
{
    print("[IGRAC-LOGIN]Dohvacanje podataka...");
    new redovi, polja;
    new temp[50];
    cache_get_data(redovi, polja);
    if(redovi)
    {
		igracStatus[playerid][logiran] = 1;
		cache_get_row(0, 3, temp);
        igracInfo[playerid][email] = temp;
		cache_get_row(0, 4, temp);
        igracInfo[playerid][novac] = strval(temp);
        cache_get_row(0, 5, temp);
        igracInfo[playerid][posao] = strval(temp);
        cache_get_row(0, 6, temp);
        igracInfo[playerid][admin] = strval(temp);
        cache_get_row(0, 7, temp);
        igracInfo[playerid][level] = strval(temp);
        cache_get_row(0, 8, temp);
        igracInfo[playerid][respect] = strval(temp);
        cache_get_row(0, 9, temp);
        igracInfo[playerid][organizacija] = strval(temp);
        cache_get_row(0, 10, temp);
        igracInfo[playerid][rank] = strval(temp);
        cache_get_row(0, 11, temp);
        igracInfo[playerid][skin] = strval(temp);
		ShowPlayerDialog(playerid, DIALOG_SUCCESS_2, DIALOG_STYLE_MSGBOX,"Uspijeh!","Uspjesno si se prijavio!","Ok","");
		SetSpawnInfo(playerid, 0, 1, -1498.3866,920.1454,7.1875, 89.4492, 0,0,0,0,0,0);
		SpawnPlayer(playerid);
		SetPlayerSkin(playerid, igracInfo[playerid][skin]);
		GivePlayerMoney(playerid, igracInfo[playerid][novac]);
		print("[IGRAC-LOGIN]Uspjesno->Spawn");
    } else {
    	igracStatus[playerid][logiran] = 0;
    	ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_INPUT,"Prijava","Kriva lozinka.\n Unesi lozinku ispod za prijavu.","Prijava","Odustani");
    }
    return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}
