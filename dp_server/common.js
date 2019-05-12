//Removes object from the array based on filter function.
function deleteFromArray(array, filter){
    let index = array.findIndex(filter);
    while(index != -1){
        array.splice(index, 1);
        index = array.findIndex(filter);
    }
    return;
}

//Updates the parameter in the array based on the filter.
function changeInArray(array, attr, value, filter){
    const index = array.findIndex(filter);
    if(index != -1){
        array[index][attr] = value;
        return;
    }
    throw new Error('Element for editing in array is not found.');
}

//Returns the value of the object attribute in array based on the filter.
function getFromArray(array, attr, filter){
    const index = array.findIndex(filter);
    if(index != -1){
        return array[index][attr];
    }
    throw new Error('Element for editing in array is not found.');
}

module.exports = {
    deleteFromArray,
    changeInArray,
    getFromArray
}