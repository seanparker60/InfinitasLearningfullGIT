({
    TXT2JSON: function (component,insertedFile) {

        // Convert Data to String and Split into Array
        var array = insertedFile.toString().split("\r");

        // All the rows of the file will be converted to JSON objects and added to the result in array
        let result = [];

        // The Array[0] contains the header collumns, we store these in the headers array
        let headers1 = array[0] // .split(";")

        let sH = '';
        let flagH = 0;
        for(let chH of headers1) {
            if (chH === '"' && flagH === 0) {
                flagH = 1;
            }
            else if (chH === '"' && flagH == 1) flagH = 0;
            if(chH === ';' && flagH === 0) chH = '|';
            if(chH !== '"') sH += chH;
        }

        let headers = sH.split("|");

        // traverse remaining n-1 rows
        for(let i = 1; i < array.length; i++) {
            let obj = {};

            // create empty object to store values of the current row
            // declare string str as current array
            // store generated string in a new String s
            let str = array[i];
            let s = '';

            // By Default, we get the values of a cell in quotes " " so we  
            // use flag to keep track of quotes and split the string accordingly 
            // If we encounter opening quote (") then we keep semicolons as it is otherwise we replace them with pipe | 
            // We keep adding the characters
            // we traverse to a String s 
            let flag = 0;
            for (let ch of str) {
                if(ch === '"' && flag === 0) {
                    flag = 1;
                }
                else if (ch === '"' && flag == 1) flag = 0;
                if(ch === ';' && flag === 0) ch = '|';
                if(ch !== '"') s += ch;
            }

            // split string using pipe delimiter
            let properties = s.split("|");

            // for each header, if the value contains multiple semicolon seperated data we store it
            // in the form of array otherwise the value is directly stored
            for (let j in headers) {
                if (properties[j].includes(";")) {
                    obj[headers[j]] = properties[j].split(";").map(item => item.trim());
                }
                else obj[headers[j]] = properties[j];
            }

            // add the generated object to our result array
            result.push(obj);
        }

        // convert the result array to JSON and generate the JSON output
        let json = JSON.stringify(result);

        console.log('### JSON Output = ' + json);
        return json;

        
    },
    
    CreateAccount : function (component,scholen,scholengemeenschappen,inrichtendeMachten){
    var action = component.get("c.insertData");
    alert('@@@ Server Action = ' + action);    
        action.setParams({
                "scholen" : scholen,
                "scholengemeenschappen" : scholengemeenschappen,
                "inrichtendeMachten" : inrichtendeMachten
            });
        action.setCallback(this, function(response) {
            var state = response.getState();
            alert(state);
            if (state === "SUCCESS") {  
            alert("Accounts Inserted Succesfully");
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                     alert('Unknown');
                }
            }
        }); 
        
        $A.enqueueAction(action);    
        
}
})