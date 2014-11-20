<%--
  ADOBE CONFIDENTIAL
  __________________

   Copyright 2014 Adobe Systems Incorporated
   All Rights Reserved.

  NOTICE:  All information contained herein is, and remains
  the property of Adobe Systems Incorporated and its suppliers,
  if any.  The intellectual and technical concepts contained
  herein are proprietary to Adobe Systems Incorporated and its
  suppliers and are protected by trade secret or copyright law.
  Dissemination of this information or reproduction of this material
  is strictly forbidden unless prior written permission is obtained
  from Adobe Systems Incorporated.
--%><%
%><%@page session="false" import="javax.jcr.*,
                                  javax.jcr.query.*,
                                  java.util.*,
                                  com.day.cq.commons.Externalizer" %>
<%@include file="/libs/foundation/global.jsp"%>

<% if (request.getParameter("path") != null) { %>
<script>

    $(document).ready(function () {
        // prefill pathbrowser with value from the url
        $(".js-coral-pathbrowser-input", $("#path").closest(".coral-Form-fieldwrapper")).val("<%= xssAPI.encodeForJSString(request.getParameter("path")) %>");
    });

</script>
<% } %>

<div id="content">

    <cq:include path="/libs/cq/ui/dialogupgrade/content/console/components/showButton" resourceType="granite/ui/components/foundation/button"/>

    <div class="left">
        <cq:include path="/libs/cq/ui/dialogupgrade/content/console/components/path" resourceType="granite/ui/components/foundation/form/pathbrowser"/>
    </div>

    <br /><br /><br />

    <%

        if (request.getParameter("path") != null && !request.getParameter("path").isEmpty()) {
            Externalizer externalizer = resourceResolver.adaptTo(Externalizer.class);
            Session session = slingRequest.getResourceResolver().adaptTo(Session.class);
            QueryManager queryManager = session.getWorkspace().getQueryManager();

            // build and execute query
            String path = request.getParameter("path");
            // todo: sql injection
            String sql = "SELECT * FROM [cq:Dialog] AS d WHERE (ISDESCENDANTNODE('"+path+"') OR [jcr:path] = '"+path+"') AND NAME(d) = 'dialog'";
            final Query query = queryManager.createQuery(sql, Query.JCR_SQL2);
            final NodeIterator results = query.execute().getNodes();
    %>
            <div id="info-text">
                Found <b><%= results.getSize() %></b> dialogs below <b><%= path %></b>
            </div>
            <br />
            <div id="dialogs">
                <table class="coral-Table coral-Table--hover">
                    <thead>
                        <tr class="coral-Table-row">
                            <th class="coral-Table-headerCell">Dialog (Classic UI)</th>
                            <th class="coral-Table-headerCell centered">Links</th>
                            <th class="coral-Table-headerCell centered">Dialog (Touch UI)</th>
                        </tr>
                    </thead>
                    <tbody>
        <%
            while(results.hasNext()) {
                Node dialog = results.nextNode();
                Node parent = dialog.getParent();
                String href = externalizer.authorLink(resourceResolver, dialog.getPath()) + ".html";
                String crxHref = externalizer.authorLink(resourceResolver, "/") + "crx/de/index.jsp#" + dialog.getPath();
                %>
                        <tr class="coral-Table-row">
                            <td class="coral-Table-cell path"><%= dialog.getPath()%></td>
                            <td class="coral-Table-cell centered"><a href="<%= xssAPI.getValidHref(href) %>" target="_blank" class="coral-Link">show</a> / <a href="<%= xssAPI.getValidHref(crxHref) %>" x-cq-linkchecker="skip" target="_blank" class="coral-Link">crxde</a></td>
                <% if (parent.hasNode("cq:dialog")) {
                    Node touchDialog = parent.getNode("cq:dialog");
                    href = externalizer.authorLink(resourceResolver, "/libs/cq/ui/dialogupgrade/content/render") + ".html" + touchDialog.getPath();
                    crxHref = externalizer.authorLink(resourceResolver, "/") + "crx/de/index.jsp#" + touchDialog.getPath().replaceAll(":", "%3A");
                %>
                            <td class="coral-Table-cell centered"><i class="coral-Icon coral-Icon--check"></i> &nbsp;&nbsp; <a href="<%= xssAPI.getValidHref(href) %>" target="_blank" class="coral-Link">show</a> / <a href="<%= xssAPI.getValidHref(crxHref) %>" x-cq-linkchecker="skip" target="_blank" class="coral-Link">crxde</a></td>
                <% } else { %>
                            <td class="coral-Table-cell centered">-</td>
                <% } %>
                        </tr>
            <% } %>
                    </tbody>
                </table>
                <br />
                <cq:include path="/libs/cq/ui/dialogupgrade/content/console/components/upgradeButton" resourceType="granite/ui/components/foundation/button"/>
            </div>

            <table class="coral-Table coral-Table--hover" id="upgrade-results">
                <thead>
                    <tr class="coral-Table-row">
                        <th class="coral-Table-headerCell">Dialog (Classic UI)</th>
                        <th class="coral-Table-headerCell centered">Upgrade to Touch UI</th>
                        <th class="coral-Table-headerCell">Message</th>
                    </tr>
                </thead>
                <tbody>
                </tbody>
            </table>
    <% } %>

</div>
