exports = async function createNewUserDocument({ user }) {
  const cluster = context.services.get("mongodb-atlas");
  const users = cluster.db("tracker").collection("users");
  return await users.insertOne({
    _partition: "My Project",
    user_id: user.id,
    name: user.data.email,
  });
};