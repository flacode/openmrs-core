<%@ include file="/WEB-INF/template/include.jsp" %>

<openmrs:htmlInclude file="/scripts/jquery/dataTables/css/dataTables.css" />
<openmrs:htmlInclude file="/scripts/jquery/dataTables/js/jquery.dataTables.min.js" />

<openmrs:htmlInclude file="/scripts/jquery-ui/js/jquery-ui-1.7.2.custom.min.js" />
<openmrs:htmlInclude file="/dwr/interface/DWRVisitService.js"/>
<link href="<openmrs:contextPath/>/scripts/jquery-ui/css/<spring:theme code='jqueryui.theme.name' />/jquery-ui.custom.css" type="text/css" rel="stylesheet" />

<script type="text/javascript">
var selectedVisitRow;
var visibleEncountersRow;
var formToEditUrlMap = {};
var editUrl = '<openmrs:contextPath />/admin/encounters/encounter.form';
var editEncounterImage = '<img src="<openmrs:contextPath />/images/edit.gif" title="<spring:message code="general.edit"/>" border="0" />';
var canEditEncounters = false;
<c:if test="${fn:length(model.formToEditUrlMap) > 0}">
<c:forEach var="entry" items="${model.formToEditUrlMap}">
	formToEditUrlMap[${entry.key}] = '${entry.value}';
</c:forEach>
</c:if>

function toggleEncounters(visitId){
	//user has selected the same visit as the one before
	if(selectedVisitRow && $j(selectedVisitRow).attr('id') == visitId){
		//just toggle the visible encounters since the user selected the same visit row
		if($j(visibleEncountersRow).is(':visible')){
			$j(visibleEncountersRow).hide();
			//remove the row highlight
			$j(selectedVisitRow).removeClass('selected-visit');
		}
		else{
			$j(visibleEncountersRow).show();
			$j(selectedVisitRow).addClass('selected-visit');
		}
		
		return;
	}
	
	//clear the table
	$j('#visitEncountersTable-'+visitId+' > tbody > tr').remove();
	if(selectedVisitRow){
		//remove the row highlight
		$j(selectedVisitRow).removeClass('selected-visit');
	}
	//hide the visible visit encounters
	if(visibleEncountersRow)
		$j(visibleEncountersRow).hide();
		
	selectedVisitRow = $j("#"+visitId);
	visibleEncountersRow = $j("#encountersRow-"+visitId);
	$j(selectedVisitRow).addClass('selected-visit');
	$j(visibleEncountersRow).show();
		
	DWRVisitService.findEncountersByVisit(visitId, function(encounters) {
		if(encounters){
			if(encounters.length > 0){
				for(var i in encounters){
					var e = encounters[i];
					var actualEditUrl = editUrl;
					if(formToEditUrlMap[e.formId] != null)
						actualEditUrl = formToEditUrlMap[e.formId];
					
					actualEditUrl = actualEditUrl+"?encounterId="+e.encounterId;
		
					$j('#visitEncountersTable-'+visitId+' tbody:last').append('<tr>'+
							((canEditEncounters) ? '<td align="center"><a href="'+actualEditUrl+'">'+editEncounterImage+'</a></td>':'')+
							'<td>'+e.encounterDateString+'</td>'+
							'<td>'+e.encounterType+'</td>'+
							'<td>'+e.providerName+'</td>'+
							'<td>'+((e.formName) ? e.formName:"")+'</td>'+
							'<td>'+e.location+'</td>'+
							'<td>'+e.entererName+'</td>'+
						'</tr>');
				}
			}else{
				$j('#visitEncountersTable-'+visitId+' tbody:last').append('<tr>'+
						'<td colspan="'+((canEditEncounters) ? 7 : 6)+'" class="centerAligned"><spring:message code="general.none"/></td>'+
					'</tr>');
			}
		}else{
			alert('<spring:message code="Visit.find.encounters.error"/>');
		}
	});
}
</script>

<style type="text/css">
.visitRow{
	cursor: pointer;
}
.visitRow:hover{
	background: #F0E68C;
}
.selected-visit{
	background-color: #A8D0F7; color: white; font-weight: bold;
}
.centerAligned{
	text-align: center;
}
</style>

<div id="portlet${model.portletUUID}">
<div id="visitPortlet">

	<openmrs:hasPrivilege privilege="View Visits">
		<div id="visits">
			<div class="boxHeader${model.patientVariation}"><c:choose><c:when test="${empty model.title}"><spring:message code="Visit.header"/></c:when><c:otherwise><spring:message code="${model.title}"/></c:otherwise></c:choose></div>
			<div class="box${model.patientVariation}">
				<openmrs:hasPrivilege privilege="Add Visits">
				&nbsp;<a href="<openmrs:contextPath />/admin/visits/visit.form?patientId=${model.patient.patientId}"><spring:message code="Visit.add"/></a>
				<br/><br/>
				</openmrs:hasPrivilege>
				<div>
					<table cellspacing="0" cellpadding="2" id="patientVisitsTable">
						<thead>
							<tr>
								<th class="visitEdit" align="center">
									<spring:message code="general.edit"/>
								</th>
								<openmrs:hasPrivilege privilege="View Encounters">
				 				<th></th>
				 				</openmrs:hasPrivilege>
								<th class="visitTypeHeader"> <spring:message code="Visit.type"/>     </th>
								<th class="visitLocationHeader"> <spring:message code="Visit.location"/> </th>
								<th class="startDatetimeHeader"> <spring:message code="Visit.startDatetime"/> </th>
								<th class="stopDatetimeHeader"> <spring:message code="Visit.stopDatetime"/> </th>
								<th class="indicationHeader"> <spring:message code="Visit.indication"/> </th>
							</tr>
						</thead>
						<tbody>
							<openmrs:forEachVisit visits="${model.patientVisits}" sortBy="startDatetime" descending="true" var="visit" num="${model.num}">
								<tr id="${visit.visitId}" class='visitRow ${status.index % 2 == 0 ? "evenRow" : "oddRow"}'>
									<td class="visitEdit" align="center">
										<openmrs:hasPrivilege privilege="Edit Visits">
											<a href="${pageContext.request.contextPath}/admin/visits/visit.form?visitId=${visit.visitId}">
												<img src="${pageContext.request.contextPath}/images/edit.gif" title="<spring:message code="general.edit"/>" border="0" />
											</a>
										</openmrs:hasPrivilege>
									</td>
									<openmrs:hasPrivilege privilege="View Encounters">
				 					<td>
										<a href="javascript:void(0)" onclick="toggleEncounters(${visit.visitId})">
											<img src="<openmrs:contextPath />/images/file.gif" title="<spring:message code="Visit.viewEncounters"/>" border="0" />
										</a>
									</td>
				 					</openmrs:hasPrivilege>
					 				<td class="visitType"><openmrs:format visitType="${visit.visitType}"/></td>
					 				<td class="visitLocation"><openmrs:format location="${visit.location}"/></td>
					 				<td class="startDatetime">
										<openmrs:formatDate date="${visit.startDatetime}" type="small" />
									</td>
									<td class="stopDatetime">
										<openmrs:formatDate date="${visit.stopDatetime}" type="small" />
									</td>
									<td class="indication"><openmrs:format concept="${visit.indication}"/></td>
								</tr>
								<tr id="encountersRow-${visit.visitId}" style="display: none">
									<td>&nbsp;</td>
									<td colspan="5">
										<table id="visitEncountersTable-${visit.visitId}" cellspacing="0" cellpadding="2">
											<thead>
				 								<tr>
				 									<openmrs:hasPrivilege privilege="Edit Encounters">
				 									<th><spring:message code="general.edit"/></th>
				 									<script type="text/javascript">canEditEncounters = true;</script>
				 									</openmrs:hasPrivilege>
				 									<th><spring:message code="Encounter.datetime"/></th>
													<th><spring:message code="Encounter.type"/></th>
													<th><spring:message code="Encounter.provider"/></th>
													<th><spring:message code="Encounter.form"/></th>
													<th><spring:message code="Encounter.location"/></th>
													<th><spring:message code="Encounter.enterer"/></th>
				 								</tr>
											</thead>
											<tbody></tbody>
										</table>
									</td>
								</tr>
							</openmrs:forEachVisit>
						</tbody>
					</table>
				</div>
			</div>
			<openmrs:hasPrivilege privilege="View Encounters">
			<br />
			<div class="boxHeader"><spring:message code="Visit.encounters.notAssignedToVisit"/></div>
			<div class="box">
				<table cellpadding="2">
					<thead>
				 	<tr>
				 		<openmrs:hasPrivilege privilege="Edit Encounters">
				 		<th><spring:message code="general.edit"/></th>
				 		</openmrs:hasPrivilege>
				 		<th><spring:message code="Encounter.datetime"/></th>
						<th><spring:message code="Encounter.type"/></th>
						<th><spring:message code="Encounter.provider"/></th>
						<th><spring:message code="Encounter.form"/></th>
						<th><spring:message code="Encounter.location"/></th>
						<th><spring:message code="Encounter.enterer"/></th>
				 	</tr>
					</thead>
					<tbody>
						<c:forEach var="enc" items="${model.otherEncounters}" varStatus="varStatus">
						<tr class='${varStatus.index % 2 == 0 ? "evenRow" : "oddRow"}'>
						<openmrs:hasPrivilege privilege="Edit Encounters">
							<td align="center">
				 			<openmrs:hasPrivilege privilege="Edit Encounters">
							<c:set var="editUrl" value="<openmrs:contextPath />/admin/encounters/encounter.form?encounterId=${enc.encounterId}"/>
							<c:if test="${ model.formToEditUrlMap[enc.form] != null }">
								<c:url var="editUrl" value="${model.formToEditUrlMap[enc.form]}">
									<c:param name="encounterId" value="${enc.encounterId}"/>
								</c:url>
							</c:if>
							<a href="${editUrl}">
								<img src="<openmrs:contextPath />/images/edit.gif" title="<spring:message code="general.edit"/>" border="0" />
							</a>
							</openmrs:hasPrivilege>
				 			</td>
				 			</openmrs:hasPrivilege>
				 			<td><openmrs:formatDate date="${enc.encounterDatetime}" type="small" /></td>
							<td><openmrs:format encounterType="${enc.encounterType}"/></td>
							<td><openmrs:format person="${enc.provider}"/></td>
							<td>${enc.form.name}</td>
							<td><openmrs:format location="${enc.location}"/></td>
							<td>${enc.creator.personName}</td>
						</tr>
						</c:forEach>
					</tbody>						
				</table>
			</div>
			</openmrs:hasPrivilege>	
		</div>
		
		<c:if test="${model.showPagination != 'true'}">
			<script type="text/javascript">
				// hide the columns in the above table if datatable isn't doing it already 
				$j(".hidden").hide();
			</script>
		</c:if>
	</openmrs:hasPrivilege>
	
</div>
</div>