<cfcomponent output="false" hint="Applicationsübergreifend Funktionen">

<cffunction name="init" returntype="config" access="public" output="false" hint="contructor">
	<cfset variables.instance = load('#expandPath('./configs/')#application.ini') />

	<cfreturn this />
</cffunction>


<cffunction name="getServerName" returntype="string" access="public" output="false" hint="Liefert den Namen der akt. Machine">
	<cfreturn listFirst(createObject('java','java.net.InetAddress').getLocalHost().getHostName(),'/') />
</cffunction>


<cffunction name="get" returntype="any" access="public" hint="liest einen Wert oder Section aus der Configuration">
	<cfargument name="profileString" type="string" required="false" default="" hint="Wert aus der 'INI-Datei' bzw. diesem Objekt lesen">

	<cfset var local = structNew() />
	<cfset local.result = variables.instance />

	<cfif len(arguments.profileString)>
		<cfset local.result = evaluate('variables.instance.#arguments.profileString#') />
	</cfif>

	<cfreturn local.result />
</cffunction>


<cffunction name="load" returntype="struct" access="public" output="false" hint="liest alle Daten die zur Navigation notwendig sind">
	<cfargument name="iniFile" type="string" required="true" hint="Pfad zur INI-Datei" />

	<cfset var local = structNew() />

	<cfset local.struct   = structNew() />
	<cfset local.myFile   = arguments.iniFile />
	<cfset local.sections = getProfileCharSections(local.myFile) />

	<cfset local.section  = "" />
	<cfset local.entry    = "" />

	<cfloop collection="#local.sections#" item="local.section">
		<cfset myStruct[local.section] = structNew() />
		<cfloop list="#local.sections[local.section]#" index="local.entry">
			<cfset local.struct[local.section][local.entry] = getProfileCharString(local.myFile,local.section,local.entry) />
		</cfloop>
	</cfloop>

	<cfreturn local.struct />
</cffunction>


<!--- docu:reinhardjung/ 2010.07.13 15:49:52 PM  Profile ReWrite mit UTF-8 --->
<cffunction name="getProfileCharSections" returntype="struct" access="public" output="false" hint="">
	<cfargument name="path" type="string" required="true" hint="Pfad zur INI-Datei" />
	<cfargument name="charset" type="string" required="false" default="utf-8" hint="Zeichensatz" />

	<cfset var local = structNew() />
	<cfset local.sections = structNew() />

	<cfinvoke component="#this#" method="read" argumentcollection="#arguments#" returnvariable="local.INIfile" />
	<cfloop from="1" to="#listLen(local.inifile,chr(10))#" index="local.line">
		<cfset local.value = trim(listGetAt(local.inifile,local.line,chr(10))) />

		<cfif left(local.value,1) IS "[">
			<cfset local.newSection = mid(local.value,2,len(local.value)-2) />
			<cfset local.sections[local.newSection] = "">
		<cfelse>
			<cfset local.sections[local.newSection] = listAppend(local.sections[local.newSection],listFirst(local.value,'=')) />
		</cfif>
	</cfloop>

	<cfreturn local.sections />
</cffunction>


<cffunction name="getProfileCharString" returntype="any" access="public" output="false" hint="">
	<cfargument name="path"			type="string" required="true" hint="Pfad zur INI-Datei" />
	<cfargument name="section"	type="string" required="true" hint="Pfad zur INI-Datei" />
	<cfargument name="entry"		type="string" required="false" default="" hint="Pfad zur INI-Datei" />
	<cfargument name="charset"	type="string" required="false" default="utf-8" hint="Zeichensatz" />

	<cfset var local = structNew() />
	<cfset local.result = "" />

	<cfinvoke component="#this#" method="ini2Struct" argumentcollection="#arguments#" returnvariable="local.struct" />

	<cfif left(trim(arguments.entry),1) NEQ chr(35)>
		<cfif len(arguments.entry)>
			<cfset local.result = evaluate('local.struct.#arguments.section#.#arguments.entry#') />
		<cfelse>
			<cfset local.result = evaluate('local.struct.#arguments.section#') />
		</cfif>
	</cfif>

	<cfreturn local.result />
</cffunction>


<cffunction name="read" returntype="string" access="public" output="false" hint="liest die Datei in eine Struktur">
	<cfargument name="path" type="string" required="true" hint="Pfad zur INI-Datei" />
	<cfargument name="charset" type="string" required="false" default="utf-8" hint="Zeichensatz" />

	<cfset var local = structNew() />
	<cffile action="read" file="#arguments.path#" variable="local.iniFile" charset="#arguments.charset#" />

	<cfreturn local.iniFile />
</cffunction>


<cffunction name="ini2Struct" returntype="struct" access="public" output="false" hint="">
	<cfargument name="path"			type="string" required="true" hint="Pfad zur INI-Datei" />

	<cfset var local = structNew() />
	<cfset local.sections = structNew() />
	<cfset local.newSection = "" />

	<cfinvoke component="#this#" method="read" argumentcollection="#arguments#" returnvariable="local.INIfile" />
	<cfloop from="1" to="#listLen(local.inifile,chr(10))#" index="local.line">
		<cfset local.value = trim(listGetAt(local.inifile,local.line,chr(10))) />

		<cfif len(local.value) AND left(local.value,1) NEQ chr(35)>
			<cfif left(local.value,1) IS "[">	<!--- wenn es eine Sesction gibt, bzw. sein soll --->
				<cfset local.newSection = mid(local.value,2,len(local.value)-2) />
			<cfelse>
				<cfif NOT structKeyExists(local.sections,local.newSection)>	<!--- eine Strucktur machen, wenn es keine gibt --->
					<cfset local.sections[local.newSection] = structNew() />
				</cfif>
				<cfset local.sections[local.newSection][listFirst(local.value,'=')] = listLast(local.value,'=') />	<!--- den Eintrag hinzufügen --->
			</cfif>
		</cfif>
	</cfloop>

	<cfreturn local.sections />
</cffunction>

</cfcomponent>