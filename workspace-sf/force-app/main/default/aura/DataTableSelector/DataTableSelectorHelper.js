({
    getColumnDefinitions: function () {
        var columnsWidths = this.getColumnWidths();
        var columns = [
            { label: 'Número', fieldName: 'Name', type: 'text', sortable: true },
            { label: 'Tipo', fieldName: 'Tipo__c', type: 'text', sortable: true },
            { label: 'Record Type Name', fieldName: 'RecordType.Name', type: 'text', sortable: true }
        ];

        if (columnsWidths.length === columns.length) {
            return columns.map(function (col, index) {
                return Object.assign(col, { initialWidth: columnsWidths[index] });
            });
        }
        return columns;
    },
    fetchData: function (cmp, fetchData, numberOfRecords) {
        cmp.set('v.data', fetchData);
    },
    sortData: function (cmp, fieldName, sortDirection) {
        var data = cmp.get("v.data");
        var reverse = sortDirection !== 'asc';

        data = Object.assign([],
            data.sort(this.sortBy(fieldName, reverse ? -1 : 1))
        );
        cmp.set("v.data", data);
    },
    sortBy: function (field, reverse, primer) {
        var key = primer
            ? function(x) { return primer(x[field]) }
            : function(x) { return x[field] };

        return function (a, b) {
            var A = key(a);
            var B = key(b);
            return reverse * ((A > B) - (B > A));
        };
    },
    storeColumnWidths: function (widths) {
        localStorage.setItem('datatable-in-action', JSON.stringify(widths));
    },
    resetLocalStorage: function () {
        localStorage.setItem('datatable-in-action', null);
    },
    getColumnWidths: function () {
        var widths = localStorage.getItem('datatable-in-action');

        try {
            widths = JSON.parse(widths);
        } catch(e) {
            return [];
        }
        return Array.isArray(widths) ? widths : [];
    },
    editRowStatus: function (cmp, row) {
        /*
        var data = cmp.get('v.data');
        data = data.map(function(rowData) {
            if (rowData.id === row.id) {
                switch(row.status) {
                    case 'Pending':
                        rowData.status = 'Approved';
                        rowData.actionLabel = 'Complete';
                        break;
                    case 'Approved':
                        rowData.status = 'Complete';
                        rowData.actionLabel = 'Close';
                        break;
                    case 'Complete':
                        rowData.status = 'Closed';
                        rowData.actionLabel = 'Closed';
                        rowData.actionDisabled = true;
                        break;
                    default:
                        break;
                }
            }
            return rowData;
        });
        cmp.set("v.data", data);
        */
    },
    showRowDetails : function(row) {
        // eslint-disable-next-line no-alert
        // alert("Showing opportunity " + row.opportunityName + " closing on " + row.closeDate);
    }
});